# Safecharge

A simple Ruby wrapper for the SafeCharge PPP Payment API v 3.0.0 (Revised July 2011), as well as
the SafeCharge Web Cashier API v1.1 (Revised 10 July 2013).

## Status

This project is under active development right now, and not suitable for use.

## Installation

Add this line to your application's Gemfile:

    gem 'safecharge'

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install safecharge

## Usage

### Public Payment Page

The SafeCharge PPP system provides a simple means for merchants to integrate credit card
payments into their site, without worrying about having to capture their customers'
credit card details.

It works like this:

Step 1)  Your website provides a way for customers to choose the items they wish to buy,
say via a shopping basket, or similar.

Collate an array of items with the following information
        
    items = [
      {
      'name' => 'bat',
      'number' => 'sku54321',
      'amount' => 25,
      'quantity' => 1
      },
      {
      'name' => 'ball',
      'number' => 'sku12345',
      'amount' => 15,
      'quantity' => 2
      }
    ]

and insert that items array into an array of params like so

    params = {
      'total_amount' => 55,
      'currency' => 'USD',
      'items' => items
    }

Note you must supply the following environment variables for this API to work.

    SAFECHARGE_SECRET_KEY, SAFECHARGE_MERCHANT_ID, SAFECHARGE_MERCHANT_SITE_ID

These will have been provided to you by Safecharge.

Step 2) You offer a `checkout` button that links to the following url.

    `url = Safecharge.request_url(params)`

Step 3) The SafeCharge system will redirect the user to the Public Payment Page
and there they will enter in their credit card and other payment details as needed.
When the user confirms their payment, the Safecharge system authenticates it and
redirects the user to either a 'success', 'failure' or 'back' page. The back page
is used if the user suspends the payment processing by clicking on their browser's
back button.

### Web Cashier

The Safecharge Web Cashier extends the standard Public Payment Page with paramaters that
allow you to register and identify customers in SafeCharge's system, and enable you to
change the deposit amounts within limits you define.

It works like this:

Step 1)  Your website provides a way for customers to choose the items they wish to buy,
say via a shopping basket, or similar.

Collate an array of items with the following information
        
    items = [
      {
      'name' => 'deposit',
      'number' => 'something',
      'amount' => 0,
      'quantity' => 1,
      'open_amount' => 'true',
      'min_amount' => 10.0,
      'max_amount' => 1000.0,
      },
    ]

and insert that items array into an array of params like so

    params = {
      'total_amount' => 55,
      'currency' => 'USD',
      'items' => items,
      'user_token' => 'auto', # or 'register'
      'user_token_id' => 'player_id'
    }

Note you must supply the following environment variables for this API to work.

    SAFECHARGE_SECRET_KEY, SAFECHARGE_MERCHANT_ID, SAFECHARGE_MERCHANT_SITE_ID

These will have been provided to you by Safecharge.

Step 2) You offer a `checkout` button that links to the following url.

    `url = Safecharge.wc_request_url(params)`

Step 3) The SafeCharge system will redirect the user to the WebCashier Page
and there they will enter in their credit card and other payment details as needed.
When the user confirms their payment, the Safecharge system authenticates it and
redirects the user to either a 'success', 'failure' or 'back' page. The back page
is used if the user suspends the payment processing by clicking on their browser's
back button.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
