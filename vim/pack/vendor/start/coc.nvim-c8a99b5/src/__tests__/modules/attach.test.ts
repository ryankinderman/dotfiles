import { Neovim } from '@chemzqm/neovim'
import events from '../../events'
import helper from '../helper'
import { pathReplace, toErrorText } from '../../attach'
import { URI } from 'vscode-uri'

let nvim: Neovim
beforeAll(async () => {
  await helper.setup()
  nvim = helper.nvim
})

afterAll(async () => {
  await helper.shutdown()
})

describe('notifications', () => {
  it('should do Log', () => {
    nvim.emit('notification', 'Log', [])
    nvim.emit('notification', 'redraw', [])
  })

  it('should do notifications', async () => {
    nvim.emit('notification', 'listNames', [])
    let called = false
    let spy = jest.spyOn(console, 'error').mockImplementation(() => {
      called = true
    })
    nvim.emit('notification', 'name_not_exists', [])
    nvim.emit('notification', 'MenuInput', [])
    await helper.waitValue(() => {
      return called
    }, true)
    spy.mockRestore()
  })
})

describe('request', () => {
  it('should get results', async () => {
    let result
    nvim.emit('request', 'listNames', [], {
      send: res => {
        result = res
      }
    })
    await helper.waitValue(() => {
      return Array.isArray(result)
    }, true)
  })

  it('should return error when plugin not ready', async () => {
    let plugin = helper.plugin
    Object.assign(plugin, { ready: false })
    let isErr
    nvim.emit('request', 'listNames', [], {
      send: (_res, isError) => {
        isErr = isError
      }
    })
    await helper.waitValue(() => {
      return isErr
    }, true)
    Object.assign(plugin, { ready: true })
  })

  it('should not throw when plugin method not found', async () => {
    let err
    nvim.emit('request', 'NotExists', [], {
      send: res => {
        err = res
      }
    })
    await helper.waitValue(() => {
      return typeof err === 'string'
    }, true)
  })
})

describe('attach', () => {
  it('should to text', () => {
    expect(toErrorText('text')).toBe('text')
  })

  it('should do path replace', () => {
    pathReplace(undefined)
    pathReplace({})
    nvim.emit('notification', 'VimEnter', [{
      '/foo': '/foo/bar'
    }])
    let filepath = URI.file('/foo/home').fsPath
    expect(filepath).toBe('/foo/bar/home')
    pathReplace({ '/foo': '/foo' })
  })

  it('should not throw on event handler error', async () => {
    events.on('CursorHold', () => {
      throw new Error('error')
    })
    let called = false
    nvim.emit('request', 'CocAutocmd', ['CursorHold'], {
      send: () => {
        called = true
      }
    })
    await helper.waitValue(() => {
      return called
    }, true)
  })
})
