"use strict";

Object.defineProperty(exports, "__esModule", {
  value: true
});

function _classCallCheck(instance, Constructor) { if (!(instance instanceof Constructor)) { throw new TypeError("Cannot call a class as a function"); } }

function _possibleConstructorReturn(self, call) { if (!self) { throw new ReferenceError("this hasn't been initialised - super() hasn't been called"); } return call && (typeof call === "object" || typeof call === "function") ? call : self; }

function _inherits(subClass, superClass) { if (typeof superClass !== "function" && superClass !== null) { throw new TypeError("Super expression must either be null or a function, not " + typeof superClass); } subClass.prototype = Object.create(superClass && superClass.prototype, { constructor: { value: subClass, enumerable: false, writable: true, configurable: true } }); if (superClass) Object.setPrototypeOf ? Object.setPrototypeOf(subClass, superClass) : subClass.__proto__ = superClass; }

var ApiError = exports.ApiError = function (_Error) {
  _inherits(ApiError, _Error);

  function ApiError() {
    _classCallCheck(this, ApiError);

    return _possibleConstructorReturn(this, (ApiError.__proto__ || Object.getPrototypeOf(ApiError)).call(this, "lol"));
  }

  return ApiError;
}(Error);
'use strict';

var _telegramMtproto = require('telegram-mtproto');

exports._newApiManager = function (config, toOptions) {
  return function () {
    return new _telegramMtproto.ApiManager(toOptions(config));
  };
};

exports._newApiManagerEmpty = function () {
  return new _telegramMtproto.ApiManager();
};

exports._mtpInvokeApi = function (method, params, options, manager) {
  return manager.mtpInvokeApi(method, params, options).catch(function (err) {
    return Promise.reject(new ApiError(err));
  });
};

exports._on = function (event, eff, manager) {
  return function () {
    manager.on(event, function (msg) {
      eff(msg)();
    });
  };
};
