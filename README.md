# Postgres Time Traveling Demo

## Getting started

To get started, clone the repo and run:

```sh
$ ./script/setup
```

Then to run the server:

```sh
$ ./script/server
```

If you visit [localhost:3000](http://localhost:3000), you should see a pet
simulator that will allow you to create and destroy a pet. Go ahead and create
one. You should see a message like:

> You have a pet named Charles and it was born less than a minute ago

## Traveling through time

Now, let's travel through time! Quit your server and then set an environment
variable that Ruby can parse as a time. For example:

```
$ TRAVEL_TO=2099-01-16 ./script/server
```

If you reload the root page, you should see that Charles is a lot older now:

> You have a pet named Charles and it was born almost 77 years ago

Now destroy Charles and create a new pet named Spot.

Quit the server again, this time relaunching it in the distant past:

```
$ TRAVEL_TO=1999-09-29 ./script/server
```

Reloading the page should now read:

> You have a pet named Spot and it will be born in over 99 years

## What's going on here?

It's very common to find either
[timecop](https://github.com/travisjeffery/timecop) or
[ActiveSupport::Testing::TimeHelpers](https://api.rubyonrails.org/v7.0.1/classes/ActiveSupport/Testing/TimeHelpers.html)
in use by a Rails test suite that needs to travel the application server to a
different time in order to exercise certain behaviors. A limitation of this
approach is that anything outside the current Ruby process will not have shifted
its time, so any time-related coordination between the system and external
services may behave unrealistically. The most common external service a Rails
app depends on is the database, but databases do not typically expose convenient
ways to fake time.

In this (admittedly trivial) example, Postgres's `now()` function was initially
set as the default for the `pets.born_at` column. Because this value is
set by the database as opposed to the application, it would be insufficient to
fake the time in Ruby if one wanted to fast-forward or rewind the combined
application through time.

To solve this, this app defines a [custom PG function called
nowish()](/db/migrate/20220411155011_create_nowish_function.rb) and uses it
everywhere in place of the built-in `now()` (or its `CURRENT_DATE` or
`CURRENT_TIMESTAMP`, or similar) helpers.

The `nowish()` function's implementation adds `pg_catalog.now()` to an offset of
seconds that the application stores in a table called
[system_configurations](/db/migrate/20220411154707_create_system_configuration.rb).
This means that if we were to choose a time to travel to in Ruby, we could also
move the database (or at least the return value of `nowish()`) to the same time
by setting this global offset. And the
[TravelsInTime](/app/lib/travels_in_time.rb) class does exactly that.

The final step in this demo is accomplished with [an
initializer](/config/initializers/perform_time_travel.rb) that both resets the
global offset whenever Rails is initialized and also performs a time travel
based on the presence of `TRAVEL_TO` environment variable. (You'll also note
that some amount of shenanigans are necessary to ensure that cookies will work
when the current time is rewound into the distant past relative to the user
agent.)

That's just about all there is to it! With this combination of pieces in place,
even a relatively complex app or test can be reliably time-traveled, so long as
each reference to the current time in one's database queries, views, and
procedures can be modified to instead call a single wrapper function like
`nowish()`.
