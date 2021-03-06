Meteor.Paypal =
  payflowAccountOptions: ->
    settings = ReactionCore.Collections.Packages.findOne({name: "reaction-paypal", shopId: ReactionCore.getShopId(), enabled: true}).settings
    if settings?.payflow_mode is true then mode = "live" else mode = "sandbox"
    options =
      mode: mode
      enabled: settings?.payflow_enabled || Meteor.settings.paypal?.payflow_enabled
      client_id: settings?.client_id || Meteor.settings.paypal?.client_id
      client_secret: settings?.client_secret || Meteor.settings.paypal?.client_secret
    return options

  expressCheckoutAccountOptions: ->
    settings = ReactionCore.Collections.Packages.findOne({name: "reaction-paypal", shopId: ReactionCore.getShopId(), enabled: true}).settings
    if settings?.express_mode is true then mode = "production" else mode = "sandbox"

    options =
      enabled: settings?.express_enabled
      mode: mode
      username: settings?.username || Meteor.settings.paypal?.username
      password: settings?.password || Meteor.settings.paypal?.password
      signature: settings?.signature || Meteor.settings.paypal?.signature
      merchantId: settings?.merchantId || Meteor.settings.paypal?.merchantId
      return_url: Meteor.absoluteUrl 'paypal/done'
      cancel_url: Meteor.absoluteUrl 'paypal/cancel'

    if options.mode is 'sandbox'
      options.url = 'https://api-3t.sandbox.paypal.com/nvp'
    else
      options.url = 'https://api-3t.paypal.com/nvp'

    return options

  # Submits a payment authorization to Paypal using PayFlow
  authorize: (cardInfo, paymentInfo, callback) ->
    Meteor.call "paypalSubmit", "authorize", cardInfo, paymentInfo, callback
    return

  # TODO - add a "charge" function that creates a new charge and captures all at once

  capture: (transactionId, amount, callback) ->
    captureDetails =
      amount:
        currency: "USD"
        total: amount
      is_final_capture: true

    Meteor.call "paypalCapture", transactionId, captureDetails, callback
    return

  #config is for the paypal configuration settings.
  config: (options) ->
    @accountOptions = options
    return

  paymentObj: ->
    intent: "sale"
    payer:
      payment_method: "credit_card"
      funding_instruments: []
    transactions: []

  #parseCardData splits up the card data and puts it into a paypal friendly format.
  parseCardData: (data) ->
    credit_card:
      type: data.type
      number: data.number
      first_name: data.first_name
      last_name: data.last_name
      cvv2: data.cvv2
      expire_month: data.expire_month
      expire_year: data.expire_year

  #parsePaymentData splits up the card data and gets it into a paypal friendly format.
  parsePaymentData: (data) ->
    amount:
      total: data.total
      currency: data.currency
