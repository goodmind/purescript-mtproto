import { ApiManager } from 'telegram-mtproto'

exports._newApiManager = (config, toOptions) => () => new ApiManager(
  toOptions(config)
)

exports._newApiManagerEmpty = () => new ApiManager()

exports._mtpInvokeApi = (method, params, options, manager) => {
  return manager(method, params, options)
    .catch(err => Promise.reject(new ApiError(err)))
}

exports._on = (event, eff, manager) => () => {
  manager.on(event, function (msg) {
    eff(msg)()
  })
}
