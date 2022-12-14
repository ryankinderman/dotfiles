'use strict'
import { CancellationToken, Disposable } from '../../util/protocol'
import BufferSync from '../../model/bufferSync'
import { CompleteOption, CompleteResult, ExtendedCompleteItem, ISource } from '../types'
import { waitImmediate } from '../../util'
import { KeywordsBuffer } from '../keywords'
import Source from '../source'

export class Buffer extends Source {
  constructor(private keywords: BufferSync<KeywordsBuffer>) {
    super({ name: 'buffer', filepath: __filename })
  }

  public get ignoreGitignore(): boolean {
    return this.getConfig('ignoreGitignore', true)
  }

  public async doComplete(opt: CompleteOption, token: CancellationToken): Promise<CompleteResult<ExtendedCompleteItem>> {
    let { bufnr, input, word, triggerForInComplete } = opt
    await waitImmediate()
    if (!triggerForInComplete) this.noMatchWords = new Set()
    if (input.length === 0 || token.isCancellationRequested) return null
    let iterables: Iterable<string>[] = []
    for (let buf of this.keywords.items) {
      if (buf.bufnr === bufnr || (this.ignoreGitignore && buf.gitIgnored)) continue
      iterables.push(buf.matchWords(0))
    }
    let items: Set<string> = new Set()
    let isIncomplete = await this.getResults(iterables, input, word, items, token)
    return {
      isIncomplete, items: Array.from(items).map(s => {
        return { word: s }
      })
    }
  }
}

export function register(sourceMap: Map<string, ISource>, keywords: BufferSync<KeywordsBuffer>): Disposable {
  let source = new Buffer(keywords)
  sourceMap.set('buffer', source)
  return Disposable.create(() => {
    source.dispose()
    sourceMap.delete('buffer')
  })
}
