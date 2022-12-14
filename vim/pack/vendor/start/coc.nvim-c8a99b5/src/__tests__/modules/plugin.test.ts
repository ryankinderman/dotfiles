import helper from '../helper'
import path from 'path'
import workspace from '../../workspace'
import { Neovim } from '@chemzqm/neovim'
import * as exportObj from '../../index'
import * as vsTypes from 'vscode-languageserver-types'

let nvim: Neovim

beforeAll(async () => {
  await helper.setup()
  nvim = helper.nvim
})

afterAll(async () => {
  await helper.shutdown()
})

afterEach(async () => {
  await helper.reset()
})

describe('exports', () => {
  it('should exports all types from vscode-languageserver-types', () => {
    const excludes = ['EOL', 'URI', 'TextDocument']
    let list: string[] = []
    for (let key of Object.keys(vsTypes)) {
      if (typeof exportObj[key] === 'undefined' && !excludes.includes(key)) {
        list.push(key)
      }
    }
    expect(list.length).toBe(0)
  })
})

describe('help tags', () => {
  it('should generate help tags', async () => {
    let root = workspace.pluginRoot
    let dir = await nvim.call('fnameescape', path.join(root, 'doc'))
    let res = await nvim.call('execute', `helptags ${dir}`) as string
    expect(res.length).toBe(0)
  })

  it('should return jumpable', async () => {
    let jumpable = await helper.plugin.cocAction('snippetCheck', false, true)
    expect(jumpable).toBe(false)
  })

  it('should show CocInfo', async () => {
    await helper.doAction('showInfo')
    let line = await nvim.line
    expect(line).toMatch('version')
  })

  it('should ensure current document created', async () => {
    await nvim.command('tabe tmp.js')
    let res = await helper.plugin.cocAction('ensureDocument')
    expect(res).toBe(true)
    let bufnr = await nvim.call('bufnr', ['%']) as number
    let doc = workspace.getDocument(bufnr)
    expect(doc).toBeDefined()
  })
})
