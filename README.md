DHC is an advanced HTTP client.
Implementing basic http-communication enhancements like interceptors, exception handling, format handling, accessing response data, configuring endpoints and placeholders and fully compatible, RFC-compliant URL-template support.

DHC uses [typhoeus](https://github.com/typhoeus/typhoeus) for low level http communication.

See [DHS](https://github.com/DePayFi/DHS), if you are searching for something more **high level** that can query webservices easily and provides an ActiveRecord like interface.

## Quick start guide

```ruby
  gem install dhc
```

or add it to your Gemfile:

```ruby
  gem 'dhc'
```

use it like:

```ruby
  response = DHC.get('http://datastore/v2/feedbacks')
  response.data.dig('items', 0)
  response.data.dig('items', 0, 'recommended')
  response.body
  response.headers
```

## Basic methods

Available are `get`, `post`, `put` & `delete`.

Other methods are available using `DHC.request(options)`.

## Request

The request class handles the http request, implements the interceptor pattern, loads configured endpoints, generates urls from url-templates and raises [exceptions](#exceptions) for any response code that is not indicating success (2xx).

```ruby
  response = DHC.request(url: 'http://depay.fi', method: :options)

  response.request.response #<DHC::Response> the associated response.

  response.request.options #<Hash> the options used for creating the request.

  response.request.params # access request params

  response.request.headers # access request headers

  response.request.url #<String> URL that is used for doing the request

  response.request.method #<Symbol> provides the used http-method
```

### Formats

You can use any of the basic methods in combination with a format like `json`:

```ruby
DHC.json.get(options)
```

Currently supported formats: `json`, `multipart`, `plain` (for no formatting)

If formats are used, headers for `Content-Type` and `Accept` are enforced by DHC, but also http bodies are translated by DHC, so you can pass bodies as ruby objects:

```ruby
DHC.json.post('http://slack', body: { text: 'Hi there' })
# Content-Type: application/json
# Accept: application/json
# Translates body to "{\"text\":\"Hi there\"}" before sending
```

#### Default format

If you use DHC's basic methods `DHC.get`, `DHC.post` etc. without any explicit format, `JSON` will be chosen as the default format.

#### Unformatted requests

In case you need to send requests without DHC formatting headers or the body, use `plain`:

```ruby
DHC.plain.post('http://endpoint', body: { weird: 'format%s2xX' })
```

##### Upload with DHC

If you want to upload data with DHC, it's recommended to use the `multipart` format:

```ruby
response = DHC.multipart.post('http://upload', body: { file })
response.headers['Location']
# Content-Type: multipart/form-data
# Leaves body unformatted
```

### Parallel requests

If you pass an array of requests to `DHC.request`, it will perform those requests in parallel.
You will get back an array of DHC::Response objects in the same order of the passed requests.

```ruby
  options = []
  options << { url: 'http://datastore/v2/feedbacks' }
  options << { url: 'http://datastore/v2/content-ads/123/feedbacks' }
  responses = DHC.request(options)
```

```ruby
DHC.request([request1, request2, request3])
# returns [response1, response2, response3]
```

### Follow redirects

```ruby
DHC.get('http://depay.fi', followlocation: true)
```

### Transfer data through the request body

Data that is transfered using the HTTP request body is transfered using the selected format, or the default `json`, so you need to provide it as a ruby object.

Also consider setting the http header for content-type or use one of the provided [formats](#formats), like `DHC.json`.

```ruby
  DHC.post('http://datastore/v2/feedbacks',
    body: feedback,
    headers: { 'Content-Type' => 'application/json' }
  )
```

### Request parameters

When using DHC, try to pass params via `params` option. It's not recommended to build a url and attach the parameters yourself:

DO
```ruby
DHC.get('http://depay.fi', params: { q: 'Restaurant' })
```

DON'T
```ruby
DHC.get('http://depay.fi?q=Restaurant')
```

#### Array Parameter Encoding

DHC can encode array parameters in URLs in two ways. The default is `:rack` which generates URL parameters compatible with Rack and Rails.

```ruby
DHC.get('http://depay.fi', params: { q: [1, 2] })
# http://depay.fi?q[]=1&q[]=2
```

Some Java-based apps expect their arrays in the `:multi` format:

```ruby
DHC.get('http://depay.fi', params: { q: [1, 2] }, params_encoding: :multi)
# http://depay.fi?q=1&q=2
```

### Request URL encoding

DHC, by default, encodes urls:

```ruby
DHC.get('http://depay.fi?q=some space')
# http://depay.fi?q=some%20space

DHC.get('http://depay.fi', params: { q: 'some space' })
# http://depay.fi?q=some%20space
```

which can be disabled:

```ruby
DHC.get('http://depay.fi?q=some space', url_encoding: false)
# http://depay.fi?q=some space
```

### Request URL-Templates

Instead of using concrete urls you can also use url-templates that contain placeholders.
This is especially handy for configuring an endpoint once and generate the url from the params when doing the request.
Since version `7.0` url templates follow the [RFC 6750](https://tools.ietf.org/html/rfc6570).

```ruby
  DHC.get('http://datastore/v2/feedbacks/{id}', params:{ id: 123 })
  # GET http://datastore/v2/feedbacks/123
```

You can also use URL templates, when [configuring endpoints](#configuring-endpoints):
```ruby
  DHC.configure do |c|
    c.endpoint(:find_feedback, 'http://datastore/v2/feedbacks/{id}')
  end

  DHC.get(:find_feedback, params:{ id: 123 }) # GET http://datastore/v2/feedbacks/123
```

If you miss to provide a parameter that is part of the url-template, it will raise an exception.

### Request timeout

Working and configuring timeouts is important, to ensure your app stays alive when services you depend on start to get really slow...

DHC forwards two timeout options directly to typhoeus:

`timeout` (in seconds) - The maximum time in seconds that you allow the libcurl transfer operation to take. Normally, name lookups can take a considerable time and limiting operations to less than a few seconds risk aborting perfectly normal operations. This option may cause libcurl to use the SIGALRM signal to timeout system calls.
`connecttimeout` (in seconds) - It should contain the maximum time in seconds that you allow the connection phase to the server to take. This only limits the connection phase, it has no impact once it has connected. Set to zero to switch to the default built-in connection timeout - 300 seconds.

```ruby
DHC.get('http://depay.fi', timeout: 5, connecttimeout: 1)
```

DHC provides a [timeout interceptor](#default-timeout-interceptor) that lets you apply default timeout values to all the requests that you are performig in your application.

### Request Agent

DHC identifies itself towards outher services, using the `User-Agent` header.

```
User-Agent DHC (9.4.2) [https://github.com/DePayFi/dhc]
```

If DHC is used in an Rails Application context, also the application name is added to the `User-Agent` header.

```
User-Agent DHC (9.4.2; MyRailsApplicationName) [https://github.com/DePayFi/dhc]
```

## Response

```ruby
  response.request #<DHC::Request> the associated request.

  response.data # JSON
  response.data.dig('something', 'nested')

  response.body #<String>

  response.code #<Fixnum>

  response.headers #<Hash>

  response.time #<Fixnum> Provides response time in ms.

  response.timeout? #true|false
```

### Accessing response data

The response data can be access with dot-notation and square-bracket notation. You can convert response data to open structs or json (if the response format is json).

```ruby
  response = DHC.request(url: 'http://datastore/entry/1')
  response.data[:name] # 'depay.fi'
```

You can also access response data directly through the response object (with square bracket notation only):

```ruby
  DHC.json.get(url: 'http://datastore/entry/1')[:name]
```

## Exceptions

Anything but a response code indicating success (2xx) raises an exception.

```ruby

  DHC.get('localhost') # UnknownError: 0
  DHC.get('http://localhost:3000') # DHC::Timeout: 0

```

You can access the response object that was causing the error.

```ruby
DHC.get('depay.fi')
rescue => e
  e.response #<DHC:Response>
  e.response.code # 403
  e.response.timeout? # false
  Rails.logger.error e
  # DHC::UnknownError: get http://depay.fi
  # Params: {:url=>"http://depay.fi", :method=>:get}
  # Response Code: 0
  # <Response Body>
```

All errors that are raise by DHC inherit from `DHC::Error`.
They are divided into `DHC::ClientError`, `DHC::ServerError`, `DHC::Timeout` and `DHC::UnkownError` and mapped according to the following status code.

```ruby
400 => DHC::BadRequest
401 => DHC::Unauthorized
402 => DHC::PaymentRequired
403 => DHC::Forbidden
403 => DHC::Forbidden
404 => DHC::NotFound
405 => DHC::MethodNotAllowed
406 => DHC::NotAcceptable
407 => DHC::ProxyAuthenticationRequired
408 => DHC::RequestTimeout
409 => DHC::Conflict
410 => DHC::Gone
411 => DHC::LengthRequired
412 => DHC::PreconditionFailed
413 => DHC::RequestEntityTooLarge
414 => DHC::RequestUriToLong
415 => DHC::UnsupportedMediaType
416 => DHC::RequestedRangeNotSatisfiable
417 => DHC::ExpectationFailed
422 => DHC::UnprocessableEntity
423 => DHC::Locked
424 => DHC::FailedDependency
426 => DHC::UpgradeRequired

500 => DHC::InternalServerError
501 => DHC::NotImplemented
502 => DHC::BadGateway
503 => DHC::ServiceUnavailable
504 => DHC::GatewayTimeout
505 => DHC::HttpVersionNotSupported
507 => DHC::InsufficientStorage
510 => DHC::NotExtended

timeout? => DHC::Timeout

anything_else => DHC::UnknownError
```

### Custom error handling (rescue)

You can provide custom error handlers to handle errors happening during the request.

If a error handler is provided nothing is raised.

If your error handler returns anything else but `nil` it replaces the response body.

```ruby
handler = ->(response){ do_something_with_response; return {name: 'unknown'} }
response = DHC.get('http://something', rescue: handler)
response.data[:name] # 'unknown'
```

### Ignore certain errors

As it's discouraged to rescue errors and then don't handle them (ruby styleguide)[https://github.com/bbatsov/ruby-style-guide#dont-hide-exceptions],
but you often want to continue working with `nil`, DHC provides the `ignore` option.

Errors listed in this option will not be raised and will leave the `response.body` and `response.data` to stay `nil`.

You can either pass the DHC error class you want to be ignored or an array of DHC error classes.

```ruby
response = DHC.get('http://something', ignore: DHC::NotFound)

response.body # nil
response.data # nil
response.error_ignored? # true
response.request.error_ignored? # true
```

## Configuration

If you want to configure DHC, do it on initialization (like in a Rails initializer, `environment.rb` or `application.rb`), otherwise you could run into the problem that certain configurations can only be set once.

You can use `DHC.configure` to prevent the initialization problem.
Take care that you only use `DHC.configure` once, because it is actually reseting previously made configurations and applies the new once.

```ruby

  DHC.configure do |c|
    c.placeholder :datastore, 'http://datastore'
    c.endpoint :feedbacks, '{+datastore}/feedbacks', params: { has_reviews: true }
    c.interceptors = [CachingInterceptor, MonitorInterceptor, TrackingIdInterceptor]
  end

```

### Configuring endpoints

You can configure endpoints, for later use, by giving them a name, a url and some parameters (optional).

```ruby
  DHC.configure do |c|
    c.endpoint(:feedbacks, 'http://datastore/v2/feedbacks', params: { has_reviews: true })
    c.endpoint(:find_feedback, 'http://datastore/v2/feedbacks/{id}')
  end

  DHC.get(:feedbacks) # GET http://datastore/v2/feedbacks
  DHC.get(:find_feedback, params:{ id: 123 }) # GET http://datastore/v2/feedbacks/123
```

Explicit request options override configured options.

```ruby
  DHC.get(:feedbacks, params: { has_reviews: false }) # Overrides configured params
```

### Configuring placeholders

You can configure global placeholders, that are used when generating urls from url-templates.

```ruby
  DHC.configure do |c|
    c.placeholder(:datastore, 'http://datastore')
    c.endpoint(:feedbacks, '{+datastore}/feedbacks', { params: { has_reviews: true } })
  end

  DHC.get(:feedbacks) # http://datastore/v2/feedbacks
```

## Interceptors

To monitor and manipulate the HTTP communication done with DHC, you can define interceptors that follow the (Inteceptor Pattern)[https://en.wikipedia.org/wiki/Interceptor_pattern].
There are some interceptors that are part of DHC already, so called [Core Interceptors](#core-interceptors), that cover some basic usecases.

### Quick start: Configure/Enable Interceptors

```ruby
DHC.configure do |c|
  c.interceptors = [DHC::Auth, DHC::Caching, DHC::DefaultTimeout, DHC::Logging, DHC::Monitoring, DHC::Prometheus, DHC::Retry, DHC::Rollbar, DHC::Zipkin]
end
```

You can only set the list of global interceptors once and you can not alter it after you set it.

### Interceptors on local request level

You can override the global list of interceptors on local request level:

```ruby
  interceptors = DHC.config.interceptors
  interceptors -= [DHC::Caching] # remove caching
  interceptors += [DHC::Retry] # add retry
  DHC.request({url: 'http://depay.fi', retry: 2, interceptors: interceptors})

  DHC.request({url: 'http://depay.fi', interceptors: []}) # no interceptor for this request at all
```

### Core Interceptors

#### Authentication Interceptor

Add the auth interceptor to your basic set of DHC interceptors.

```ruby
  DHC.configure do |c|
    c.interceptors = [DHC::Auth]
  end
```

##### Bearer Authentication

```ruby
  DHC.get('http://depay.fi', auth: { bearer: -> { access_token } })
```

Adds the following header to the request:
```
  'Authorization': 'Bearer 123456'
```

Assuming the method `access_token` responds on runtime of the request with `123456`.

###### Refresh Bearer Authentication

If you configure `expires_at` and `refresh` proc in addition to `bearer`, DHC will refresh the bearer token using the defined `refresh` proc in two cases:

1. before the request if `expires_at.call` < `DateTime.now + 1.minute`
2. if the request fails and `refresh(response)` responds to true

```ruby
refresh = ->(response = nil){
  if response
    if response.code == 401 && response.data && response.data[:error_code] == 'ACCESS_TOKEN_EXPIRED'
      session[:access_token] = new_access_token
    end
  else
    session[:access_token] = new_access_token
  end
}

DHC.get('http://depay.fi', auth: { bearer: -> { session[:access_token] }, refresh: refresh, expires_at: -> { session[:expires_at] } })
```

##### Basic Authentication

```ruby
  DHC.get('http://depay.fi', auth: { basic: { username: 'steve', password: 'can' } })
```

Adds the following header to the request:
```
  'Authorization': 'Basic c3RldmU6Y2Fu'
```

Which is the base64 encoded credentials "username:password".

##### Body Authentication

```ruby
  DHC.post('http://depay.fi', auth: { body: { userToken: 'dheur5hrk3' } })
```

Adds the following to body of all requests:

```
  {
    "userToken": "dheur5hrk3"
  }
```

##### Reauthenticate

The current implementation can only offer reauthenticate for _client access tokens_. For this to work the following has to be given:

* You have configured and implemented `DHC::Auth.refresh_client_token = -> { TokenRefreshUtil.client_access_token(true) }` which when called will force a refresh of the token and return the new value. It is also expected that this implementation will handle invalidating caches if necessary.
* Your interceptors contain `DHC::Auth` and `DHC::Retry`, whereas `DHC::Retry` comes _after_ `DHC::Auth` in the chain.

##### Bearer Authentication with client access token

Reauthentication will be initiated if:

* setup is correct
* `response.success?` is false and an `DHC::Unauthorized` was observed
* reauthentication wasn't already attempted once

If this is the case, this happens:

* refresh the client token, by calling `refresh_client_token`
* the authentication header will be updated with the new token
* `DHC::Retry` will be triggered by adding `retry: { max: 1 }` to the request options

#### Caching Interceptor

Add the cache interceptor to your basic set of DHC interceptors.

```ruby
  DHC.configure do |c|
    c.interceptors = [DHC::Caching]
  end
```

You can configure your own cache (default Rails.cache) and logger (default Rails.logger):

```ruby
  DHC::Caching.cache = ActiveSupport::Cache::MemoryStore.new
```

Caching is not enabled by default, although you added it to your basic set of interceptors.
If you want to have requests served/stored and stored in/from cache, you have to enable it by request.

```ruby
  DHC.get('http://depay.fi', cache: true)
```

You can also enable caching when configuring an endpoint in LHS.

```ruby
  class Feedbacks < LHS::Service
    endpoint '{+datastore}/v2/feedbacks', cache: true
  end
```

Only GET requests are cached by default. If you want to cache any other request method, just configure it:

```ruby
  DHC.get('http://depay.fi', cache: { methods: [:get] })
```

Responses served from cache are marked as served from cache:

```ruby
  response = DHC.get('http://depay.fi', cache: true)
  response.from_cache? # true
```

You can also use a central http cache to be used by the `DHC::Caching` interceptor.

If you configure a local and a central cache, DHC will perform multi-level-caching.
DHC will try to retrieve cached information first from the central, in case of a miss from the local cache, while writing back into both.

```ruby
  DHC::Caching.central = {
    read: 'redis://$PASSWORD@central-http-cache-replica.namespace:6379/0',
    write: 'redis://$PASSWORD@central-http-cache-master.namespace:6379/0'
  }
```

##### Options

```ruby
  DHC.get('http://depay.fi', cache: { key: 'key' expires_in: 1.day, race_condition_ttl: 15.seconds, use: ActiveSupport::Cache::MemoryStore.new })
```

`expires_in` - lets the cache expires every X seconds.

`key` - Set the key that is used for caching by using the option. Every key is prefixed with `DHC_CACHE(v1): `.

`race_condition_ttl` - very useful in situations where a cache entry is used very frequently and is under heavy load.
If a cache expires and due to heavy load several different processes will try to read data natively and then they all will try to write to cache.
To avoid that case the first process to find an expired cache entry will bump the cache expiration time by the value set in `race_condition_ttl`.

`use` - Set an explicit cache to be used for this request. If this option is missing `DHC::Caching.cache` is used.

#### Default Timeout Interceptor

Applies default timeout values to all requests made in an application, that uses DHC.

```ruby
  DHC.configure do |c|
    c.interceptors = [DHC::DefaultTimeout]
  end
```

`timeout` default: 15 seconds
`connecttimeout` default: 2 seconds

##### Overwrite defaults

```ruby
DHC::DefaultTimeout.timeout = 5 # seconds
DHC::DefaultTimeout.connecttimeout = 3 # seconds
```

#### Logging Interceptor

The logging interceptor logs all requests done with DHC to the Rails logs.

##### Installation

```ruby
  DHC.configure do |c|
    c.interceptors = [DHC::Logging]
  end

  DHC::Logging.logger = Rails.logger
```

##### What and how it logs

The logging Interceptor logs basic information about the request and the response:

```ruby
DHC.get('http://depay.fi')
# Before DHC request<70128730317500> GET http://depay.fi at 2018-05-23T07:53:19+02:00 Params={} Headers={\"User-Agent\"=>\"Typhoeus - https://github.com/typhoeus/typhoeus\", \"Expect\"=>\"\"}
# After DHC response for request<70128730317500>: GET http://depay.fi at 2018-05-23T07:53:28+02:00 Time=0ms URL=http://depay.fi:80/
```

##### Configure

You can configure the logger beeing used by the logging interceptor:

```ruby
DHC::Logging.logger = Another::Logger
```

#### Monitoring Interceptor

The monitoring interceptor reports all requests done with DHC to a given StatsD instance.

##### Installation

```ruby
  DHC.configure do |c|
    c.interceptors = [DHC::Monitoring]
  end
```

You also have to configure statsd in order to have the monitoring interceptor report.

```ruby
  DHC::Monitoring.statsd = <your-instance-of-statsd>
```

##### Environment

By default, the monitoring interceptor uses Rails.env to determine the environment. In case you want to configure that, use:

```ruby
DHC::Monitoring.env = ENV['DEPLOYMENT_TYPE'] || Rails.env
```

##### What it tracks

It tracks request attempts with `before_request` and `after_request` (counts).

In case your workers/processes are getting killed due limited time constraints,
you are able to detect deltas with relying on "before_request", and "after_request" counts:

###### Before and after request tracking

```ruby
  "dhc.<app_name>.<env>.<host>.<http_method>.before_request", 1
  "dhc.<app_name>.<env>.<host>.<http_method>.after_request", 1
```

###### Response tracking

In case of a successful response it reports the response code with a count and the response time with a gauge value.

```ruby
  DHC.get('http://depay.fi')

  "dhc.<app_name>.<env>.<host>.<http_method>.count", 1
  "dhc.<app_name>.<env>.<host>.<http_method>.200", 1
  "dhc.<app_name>.<env>.<host>.<http_method>.time", 43
```

In case of a unsuccessful response it reports the response code with a count but no time:

```ruby
  DHC.get('http://depay.fi')

  "dhc.<app_name>.<env>.<host>.<http_method>.count", 1
  "dhc.<app_name>.<env>.<host>.<http_method>.500", 1
```

###### Timeout tracking

Timeouts are also reported:

```ruby
  "dhc.<app_name>.<env>.<host>.<http_method>.timeout", 1
```

All the dots in the host are getting replaced with underscore, because dot is the default separator in graphite.

###### Caching tracking

When you want to track caching stats please make sure you have enabled the `DHC::Caching` and the `DHC::Monitoring` interceptor.

Make sure that the `DHC::Caching` is listed before `DHC::Monitoring` interceptor when configuring interceptors:

```ruby
DHC.configure do |c|
  c.interceptors = [DHC::Caching, DHC::Monitoring]
end
```

If a response was served from cache it tracks:

```ruby
  "dhc.<app_name>.<env>.<host>.<http_method>.cache.hit", 1
```

If a response was not served from cache it tracks:

```ruby
  "dhc.<app_name>.<env>.<host>.<http_method>.cache.miss", 1
```

##### Configure

It is possible to set the key for Monitoring Interceptor on per request basis:

```ruby
  DHC.get('http://depay.fi', monitoring_key: 'local_website')

  "local_website.count", 1
  "local_website.200", 1
  "local_website.time", 43
```

If you use this approach you need to add all namespaces (app, environment etc.) to the key on your own.


#### Prometheus Interceptor

Logs basic request/response information to prometheus.

```ruby
  require 'prometheus/client'

  DHC.configure do |c|
    c.interceptors = [DHC::Prometheus]
  end

  DHC::Prometheus.client = Prometheus::Client
  DHC::Prometheus.namespace = 'web_location_app'
```

```ruby
  DHC.get('http://depay.fi')
```

- Creates a prometheus counter that receives additional meta information for: `:code`, `:success` and `:timeout`.

- Creates a prometheus histogram for response times in milliseconds.


#### Retry Interceptor

If you enable the retry interceptor, you can have DHC retry requests for you:

```ruby
  DHC.configure do |c|
    c.interceptors = [DHC::Retry]
  end

  response = DHC.get('http://depay.fi', retry: true)
```

It will try to retry the request up to 3 times (default) internally, before it passes the last response back, or raises an error for the last response.

Consider, that all other interceptors will run for every single retry.

##### Limit the amount of retries while making the request

```ruby
  DHC.get('http://depay.fi', retry: { max: 1 })
```

##### Change the default maximum of retries of the retry interceptor

```ruby
  DHC::Retry.max = 3
```

##### Retry all requests

If you want to retry all requests made from your application, you just need to configure it globally:

```ruby
  DHC::Retry.all = true
  configuration.interceptors = [DHC::Retry]
```

##### Do not retry certain response codes

If you do not want to retry based on certain response codes, use retry in combination with explicit `ignore`:

```ruby
  DHC.get('http://depay.fi', ignore: DHC::NotFound, retry: { max: 1 })
```

Or if you use `DHC::Retry.all`:

```ruby
DHC.get('http://depay.fi', ignore: DHC::NotFound)
```

#### Rollbar Interceptor

Forward errors to rollbar when exceptions occur during http requests.

```ruby
  DHC.configure do |c|
    c.interceptors = [DHC::Rollbar]
  end
```

```ruby
  DHC.get('http://depay.fi')
```

If it raises, it forwards the request and response object to rollbar, which contain all necessary data.

##### Forward additional parameters

```ruby
  DHC.get('http://depay.fi', rollbar: { tracking_key: 'this particular request' })
```

#### Throttle

The throttle interceptor allows you to raise an exception if a predefined quota of a provider request limit is reached in advance.

The throttle state (tracker) is stored in Rails.cache.

```ruby
  DHC.configure do |c|
    c.interceptors = [DHC::Throttle]
  end
```
```ruby
options = {
  throttle: {
    track: true,
    break: '80%',
    provider: 'depay.fi',
    limit: { header: 'Rate-Limit-Limit' },
    remaining: { header: 'Rate-Limit-Remaining' },
    expires: { header: 'Rate-Limit-Reset' }
  }
}

DHC.get('http://depay.fi', options)
# { headers: { 'Rate-Limit-Limit' => 100, 'Rate-Limit-Remaining' => 19 } }

DHC.get('http://depay.fi', options)
# raises DHC::Throttle::OutOfQuota: Reached predefined quota for depay.fi
```

**Options Description**
* `track`: enables tracking of current limit/remaining requests of rate-limiting
* `break`: quota in percent after which errors are raised. Percentage symbol is optional, values will be converted to integer (e.g. '23.5' will become 23)
* `provider`: name of the provider under which throttling tracking is aggregated,
* `limit`:
  * a hard-coded integer
  * a hash pointing at the response header containing the limit value
  * a proc that receives the response as argument and returns the limit value
* `remaining`:
  * a hash pointing at the response header containing the current amount of remaining requests
  * a proc that receives the response as argument and returns the current amount of remaining requests
  * not set: will track remaining by counting down limit until `expires`
* `expires`:
  * a hash pointing at the response header containing the timestamp when the quota will reset
  * a proc that receives the response as argument and returns the timestamp when the quota will reset
  * an ActiveSupport::Duration e.g. 1.minute

Example for throttling manually without relating to any information in the response:

```ruby
options = {
  throttle: {
    track: true,
    break: '80%',
    provider: 'depay.fi',
    limit: 100,
    expires: 1.minute
  }
}

DHC.get('http://depay.fi', options)
```

Will reset every minute, and will allow up to 80 requests per minute. The 81st request attempt within a minute will raise:

```ruby
DHC::Throttle::OutOfQuota: Reached predefined quota for depay.fi
```

#### Zipkin

** Zipkin 0.33 breaks our current implementation of the Zipkin interceptor **

Zipkin is a distributed tracing system. It helps gather timing data needed to troubleshoot latency problems in microservice architectures [Zipkin Distributed Tracing](https://zipkin.io/).

Add the zipkin interceptor to your basic set of DHC interceptors.

```ruby
  DHC.configure do |c|
    c.interceptors = [DHC::Zipkin]
  end
```

The following configuration needs to happen in the application that wants to run this interceptor:

1. Add `gem 'zipkin-tracer', '< 0.33.0'` to your Gemfile.
2. Add the necessary Rack middleware and configuration

```ruby
config.middleware.use ZipkinTracer::RackHandler, {
  service_name: 'service-name', # name your service will be known as in zipkin
  service_port: 80, # the port information that is sent along the trace
  json_api_host: 'http://zipkin-collector', # the zipkin endpoint
  sample_rate: 1 # sample rate, where 1 = 100% of all requests, and 0.1 is 10% of all requests
}
```

### Create an interceptor from scratch

```ruby
  class TrackingIdInterceptor < DHC::Interceptor

    def before_request
      request.params[:tid] = 123
    end
  end
```

```ruby
  DHC.configure do |c|
    c.interceptors = [TrackingIdInterceptor]
  end
```

#### Interceptor callbacks

`before_init` is called before the raw typhoeus request has been initialized.

`before_request` is called when the request is prepared and about to be executed.

`after_request` is called after request was started.

`before_response` is called when response started to arrive.

`after_response` is called after the response arrived completely.


#### Interceptor request/response

Every interceptor can directly access their instance [request](#request) or [response](#response).

#### Provide a response replacement through an interceptor

Inside an interceptor, you are able to provide a response, rather then doing a real request.
This is useful for implementing e.g. caching.

```ruby
class DHC::Cache < DHC::Interceptor

  def before_request(request)
    cached_response = Rails.cache.fetch(request.url)
    return DHC::Response.new(cached_response) if cached_response
  end
end
```

Take care that having more than one interceptor trying to return a response will cause an exception.
You can access the request.response to identify if a response was already provided by another interceptor.

```ruby
  class RemoteCacheInterceptor < DHC::Interceptor

    def before_request(request)
      return unless request.response.nil?
      return DHC::Response.new(remote_cache)
    end
  end
```

## Testing

When writing tests for your application when using DHC, please make sure you require the dhc rspec test helper:

```ruby
# spec/spec_helper.rb

require 'dhc/rspec'
```

## License

[GNU General Public License Version 3.](https://www.gnu.org/licenses/gpl-3.0.en.html)
