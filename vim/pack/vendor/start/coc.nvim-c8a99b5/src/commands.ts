'use strict'
import { Neovim } from '@chemzqm/neovim'
import { v4 as uuid } from 'uuid'
import { writeHeapSnapshot } from 'v8'
import { CodeAction, Command as VCommand, Location, Position, Range, TextDocumentEdit, WorkspaceEdit } from 'vscode-languageserver-types'
import { URI } from 'vscode-uri'
import events from './events'
import Mru from './model/mru'
import type Plugin from './plugin'
import { wait } from './util'
import { Extensions as ExtensionsInfo, IExtensionRegistry } from './util/extensionRegistry'
import { os, path } from './util/node'
import { Disposable } from './util/protocol'
import { Registry } from './util/registry'
import { toText } from './util/string'
import type { Window } from './window'
import type { Workspace } from './workspace'

// command center
export interface Command {
  readonly id: string | string[]
  execute(...args: any[]): void | Promise<any>
}

class CommandItem implements Disposable, Command {
  constructor(
    public id: string,
    private impl: (...args: any[]) => void,
    private thisArg: any,
    public internal = false
  ) {
  }

  public execute(...args: any[]): void | Promise<any> {
    let { impl, thisArg } = this
    return impl.apply(thisArg, args || [])
  }

  public dispose(): void {
    this.thisArg = null
    this.impl = null
  }
}

const extensionRegistry = Registry.as<IExtensionRegistry>(ExtensionsInfo.ExtensionContribution)

export class CommandManager implements Disposable {
  private readonly commands = new Map<string, CommandItem>()
  public titles = new Map<string, string>()
  private mru: Mru

  public init(nvim: Neovim, plugin: Plugin): void {
    this.mru = this.workspace.createMru('commands')
    this.register({
      id: 'vscode.open',
      execute: async (url: string | URI) => {
        nvim.call('coc#ui#open_url', url.toString(), true)
      }
    }, true)
    this.register({
      id: 'workbench.action.reloadWindow',
      execute: async () => {
        nvim.command('CocRestart', true)
      }
    }, true)
    this.register({
      id: 'editor.action.doCodeAction',
      execute: async (action: CodeAction) => {
        await plugin.cocAction('doCodeAction', action)
      }
    }, true)
    this.register({
      id: 'editor.action.triggerSuggest',
      execute: async () => {
        nvim.call('coc#refresh', [], true)
      }
    }, true)
    this.register({
      id: 'editor.action.triggerParameterHints',
      execute: async () => {
        await plugin.cocAction('showSignatureHelp')
      }
    }, true)
    this.register({
      id: 'editor.action.addRanges',
      execute: async (ranges: Range[]) => {
        await plugin.cocAction('addRanges', ranges)
      }
    }, true)
    this.register({
      id: 'editor.action.restart',
      execute: async () => {
        await wait(30)
        nvim.command('CocRestart', true)
      }
    }, true)
    this.register({
      id: 'editor.action.showReferences',
      execute: async (_filepath: string, _position: Position, references: Location[]) => {
        await this.workspace.showLocations(references)
      }
    }, true)
    this.register({
      id: 'editor.action.rename',
      execute: async (uri: string, position: Position) => {
        await this.workspace.jumpTo(uri, position)
        await plugin.cocAction('rename')
      }
    }, true)
    this.register({
      id: 'editor.action.format',
      execute: async () => {
        await plugin.cocAction('format')
      }
    }, true)
    this.register({
      id: 'workspace.refactor',
      execute: async (locations: Location[]) => {
        let locs = locations.filter(o => Location.is(o))
        await plugin.getHandler().refactor.fromLocations(locs)
      }
    }, true)
    this.register({
      id: 'workspace.clearWatchman',
      execute: async () => {
        let res = await this.window.runTerminalCommand('watchman watch-del-all')
        if (res.success) void this.window.showInformationMessage('Cleared watchman watching directories.')
      }
    }, false, 'run watch-del-all for watchman to free up memory.')
    this.register({
      id: 'workspace.workspaceFolders',
      execute: async () => {
        let folders = this.workspace.workspaceFolders
        let lines = folders.map(folder => URI.parse(folder.uri).fsPath)
        await this.window.echoLines(lines)
      }
    }, false, 'show opened workspaceFolders.')

    this.register({
      id: 'workspace.renameCurrentFile',
      execute: async () => {
        await this.workspace.renameCurrent()
      }
    }, false, 'change current filename to a new name and reload it.')
    this.register({
      id: 'extensions.toggleAutoUpdate',
      execute: async () => {
        let config = this.workspace.getConfiguration('coc.preferences', null)
        let interval = config.get<string>('extensionUpdateCheck', 'daily')
        if (interval == 'never') {
          await config.update('extensionUpdateCheck', 'daily', true)
          await this.window.showInformationMessage('Extension auto update enabled.')
        } else {
          await config.update('extensionUpdateCheck', 'never', true)
          await this.window.showInformationMessage('Extension auto update disabled.')
        }
      }
    }, false, 'toggle auto update of extensions.')
    this.register({
      id: 'workspace.showOutput',
      execute: async (name?: string) => {
        if (!name) name = await this.window.showQuickPick(this.workspace.channelNames, { title: 'Choose output name' }) as string
        if (!name) return
        this.window.showOutputChannel(name)
      }
    }, false, 'open output buffer to show output from languageservers or extensions.')
    this.register({
      id: 'document.showIncomingCalls',
      execute: async () => {
        await plugin.cocAction('showIncomingCalls')
      }
    }, false, 'show incoming calls in tree view.')
    this.register({
      id: 'document.showOutgoingCalls',
      execute: async () => {
        await plugin.cocAction('showOutgoingCalls')
      }
    }, false, 'show outgoing calls in tree view.')
    this.register({
      id: 'document.echoFiletype',
      execute: async () => {
        let bufnr = await nvim.call('bufnr', '%') as number
        let doc = this.workspace.getAttachedDocument(bufnr)
        await this.window.echoLines([doc.filetype])
      }
    }, false, 'echo the mapped filetype of the current buffer')
    this.register({
      id: 'document.renameCurrentWord',
      execute: async () => {
        let bufnr = await nvim.call('bufnr', '%') as number
        let doc = this.workspace.getAttachedDocument(bufnr)
        let edit = await plugin.cocAction('getWordEdit') as WorkspaceEdit
        if (!edit) {
          void this.window.showWarningMessage('Invalid position')
          return
        }
        let ranges: Range[] = []
        let { changes, documentChanges } = edit
        if (changes) {
          let edits = changes[doc.uri]
          if (edits) ranges = edits.map(e => e.range)
        } else if (documentChanges) {
          for (let c of documentChanges) {
            if (TextDocumentEdit.is(c) && c.textDocument.uri == doc.uri) {
              ranges = c.edits.map(e => e.range)
            }
          }
        }
        if (ranges.length) {
          await plugin.cocAction('addRanges', ranges)
        }
      }
    }, false, 'rename word under cursor in current buffer by use multiple cursors.')
    this.register({
      id: 'document.jumpToNextSymbol',
      execute: async () => {
        let doc = await this.workspace.document
        if (!doc) return
        let ranges = await plugin.cocAction('symbolRanges') as Range[]
        if (!ranges) return
        let { textDocument } = doc
        let offset = await this.window.getOffset()
        ranges.sort((a, b) => {
          if (a.start.line != b.start.line) {
            return a.start.line - b.start.line
          }
          return a.start.character - b.start.character
        })
        for (let i = 0; i <= ranges.length - 1; i++) {
          if (textDocument.offsetAt(ranges[i].start) > offset) {
            await this.window.moveTo(ranges[i].start)
            return
          }
        }
        await this.window.moveTo(ranges[0].start)
      }
    }, false, 'Jump to next symbol highlight position.')
    this.register({
      id: 'workspace.undo',
      execute: async () => {
        await this.workspace.files.undoWorkspaceEdit()
      }
    }, false, 'Undo previous this.workspace edit')
    this.register({
      id: 'workspace.redo',
      execute: async () => {
        await this.workspace.files.redoWorkspaceEdit()
      }
    }, false, 'Redo previous this.workspace edit')
    this.register({
      id: 'workspace.inspectEdit',
      execute: async () => {
        await this.workspace.files.inspectEdit()
      }
    }, false, 'Inspect previous this.workspace edit in new tab')
    this.register({
      id: 'workspace.openLocation',
      execute: async (winid: number, loc: Location, openCommand?: string) => {
        if (winid) await nvim.call('win_gotoid', [winid])
        await this.workspace.jumpTo(loc.uri, loc.range.start, openCommand)
      }
    }, true)
    this.register({
      id: 'document.jumpToPrevSymbol',
      execute: async () => {
        let doc = await this.workspace.document
        if (!doc) return
        let ranges = await plugin.cocAction('symbolRanges') as Range[]
        if (!ranges) return
        let { textDocument } = doc
        let offset = await this.window.getOffset()
        ranges.sort((a, b) => {
          if (a.start.line != b.start.line) {
            return a.start.line - b.start.line
          }
          return a.start.character - b.start.character
        })
        for (let i = ranges.length - 1; i >= 0; i--) {
          if (textDocument.offsetAt(ranges[i].end) < offset) {
            await this.window.moveTo(ranges[i].start)
            return
          }
        }
        await this.window.moveTo(ranges[ranges.length - 1].start)
      }
    }, false, 'Jump to previous symbol highlight position.')
    this.register({
      id: 'document.checkBuffer',
      execute: async () => {
        await plugin.cocAction('bufferCheck')
      }
    }, false, 'Check providers for current buffer.')
    this.register({
      id: 'workspace.writeHeapSnapshot',
      execute: async () => {
        let filepath = path.join(os.homedir(), `${uuid()}-${process.pid}.heapsnapshot`)
        writeHeapSnapshot(filepath)
        void this.window.showInformationMessage(`Create heapdump at: ${filepath}`)
      }
    }, false, 'Generates a snapshot of the current V8 heap and writes it to a JSON file.')
  }

  private get window(): Window {
    return require('./window').default
  }

  private get workspace(): Workspace {
    return require('./workspace').default
  }

  public get commandList(): { id: string, title: string }[] {
    let res: { id: string, title: string }[] = []
    for (let item of this.commands.values()) {
      if (!item.internal) {
        let { id } = item
        let title = this.titles.get(id) ?? extensionRegistry.getCommandTitle(id)
        res.push({ id, title: toText(title) })
      }
    }
    return res
  }

  public dispose(): void {
    for (const registration of this.commands.values()) {
      registration.dispose()
    }
    this.commands.clear()
  }

  public execute(command: VCommand): Promise<any> {
    return this.executeCommand(command.command, ...(command.arguments ?? []))
  }

  public register<T extends Command>(command: T, internal = false, description?: string): T {
    for (const id of Array.isArray(command.id) ? command.id : [command.id]) {
      this.registerCommand(id, command.execute, command, internal)
      if (description) this.titles.set(id, description)
    }
    return command
  }

  public has(id: string): boolean {
    return this.commands.has(id)
  }

  public unregister(id: string): void {
    let item = this.commands.get(id)
    if (!item) return
    item.dispose()
    this.commands.delete(id)
  }

  /**
   * Registers a command that can be invoked via a keyboard shortcut,
   * a menu item, an action, or directly.
   *
   * Registering a command with an existing command identifier twice
   * will cause an error.
   *
   * @param command A unique identifier for the command.
   * @param impl A command handler function.
   * @param thisArg The `this` context used when invoking the handler function.
   * @return Disposable which unregisters this command on disposal.
   */
  public registerCommand(id: string, impl: (...args: any[]) => void, thisArg?: any, internal = false): Disposable {
    if (id.startsWith("_")) internal = true
    this.commands.set(id, new CommandItem(id, impl, thisArg, internal))
    return Disposable.create(() => {
      this.commands.delete(id)
    })
  }

  /**
   * Executes the command denoted by the given command identifier.
   *
   * * *Note 1:* When executing an editor command not all types are allowed to
   * be passed as arguments. Allowed are the primitive types `string`, `boolean`,
   * `number`, `undefined`, and `null`, as well as [`Position`](#Position), [`Range`](#Range), [`URI`](#URI) and [`Location`](#Location).
   * * *Note 2:* There are no restrictions when executing commands that have been contributed
   * by extensions.
   *
   * @param command Identifier of the command to execute.
   * @param rest Parameters passed to the command function.
   * @return A promise that resolves to the returned value of the given command. `undefined` when
   * the command handler function doesn't return anything.
   */
  public executeCommand<T>(command: string, ...rest: any[]): Promise<T> {
    let cmd = this.commands.get(command)
    if (!cmd) throw new Error(`Command: ${command} not found`)
    return Promise.resolve(cmd.execute.apply(cmd, rest))
  }

  /**
   * Used for user invoked command.
   */
  public async fireCommand(id: string, ...args: any[]): Promise<unknown> {
    // needed to load onCommand extensions
    await events.fire('Command', [id])
    let start = Date.now()
    let res = await this.executeCommand(id, ...args)
    if (args.length == 0) {
      await this.addRecent(id, events.lastChangeTs > start)
    }
    return res
  }

  public async addRecent(cmd: string, repeat: boolean): Promise<void> {
    await this.mru.add(cmd)
    if (repeat) await this.workspace.nvim.command(`silent! call repeat#set("\\<Plug>(coc-command-repeat)", -1)`)
  }

  public async repeatCommand(): Promise<void> {
    let mruList = await this.mru.load()
    let first = mruList[0]
    if (first) {
      await this.executeCommand(first)
      await this.workspace.nvim.command(`silent! call repeat#set("\\<Plug>(coc-command-repeat)", -1)`)
    }
  }
}

export default new CommandManager()
