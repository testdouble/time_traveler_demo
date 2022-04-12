# Postgres Time Traveling Demo

## Getting started

To get started, clone the repo and run:

```sh
$ ./script/setup
```

## Traveling through time

We're going to use this demo app to track moon landings, but because humans
haven't been landing on the moon very often lately, we need to to travel through
time to populate our database.

Let's start by running the server:

```sh
$ ./script/server
```

Now visit [localhost:3000](http://localhost:3000).

You should see a form like this:

<img width="589" alt="Screen Shot 2022-04-12 at 13 25 10" src="https://user-images.githubusercontent.com/79303/163032504-f6248c67-e7b9-4e8a-a8a2-4750da8b6a48.png">

Let's log a fake moon landing named "SpaceZ" and create the record:

<img width="589" alt="Screen Shot 2022-04-12 at 13 27 07" src="https://user-images.githubusercontent.com/79303/163032566-55580502-1c5e-4674-aa10-74cb03f8215e.png">

You'll see that the current timestamp determines the moon landing time (and
worth noting that it's the _database_ that's populating this default as opposed
to Rails).

Click `Delete` under the record and get ready to record a few **real** moon
landings.

To do this, first stop the server and then start it again, this time with a
`TRAVEL_TO` environment variable set for the date of the Apollo 11 landing:

```sh
$ TRAVEL_TO=1969-07-20 ./script/server
```

Now create a moon landing named "Apollo 11". In fact, try adding [a few more
moon
landings](https://en.wikipedia.org/wiki/Moon_landing#Human_Moon_landings_(1969–1972))
by repeating this process of time-traveling to the intended date and creating a
new record.

If you restart the app without setting a `TRAVEL_TO` env var, you should see the
relative dates all correctly faked:

<img width="574" alt="Screen Shot 2022-04-12 at 14 05 29" src="https://user-images.githubusercontent.com/79303/163032627-c3b999fe-0eaf-4812-885e-0291285c47a9.png">

You can travel into the future, too! Suppose we [go
back](https://www.nasa.gov/press-release/nasa-provides-update-to-astronaut-moon-lander-plans-under-artemis)
in a few years with an Artemis I lander:

```
$ TRAVEL_TO=2027-07-15 ./script/server
```

Adding that record and restarting without the environment variable, should
result in a final lineup of moon landings like this:

<img width="574" alt="Screen Shot 2022-04-12 at 14 47 18" src="https://user-images.githubusercontent.com/79303/163032958-995cd6e8-80db-4d78-b673-09a12f639f50.png">

## What's going on here?

It's very common to find either
[timecop](https://github.com/travisjeffery/timecop) or
[ActiveSupport::Testing::TimeHelpers](https://api.rubyonrails.org/v7.0.1/classes/ActiveSupport/Testing/TimeHelpers.html)
in use by a Rails test suite in order to manipulate the application's perception
of time in order to exercise certain behaviors. A limitation of this
approach is that anything outside the current Ruby process will not have shifted
its time, so any time-related coordination between the system and external
services may behave unrealistically. The most common external service a Rails
app depends on is the database, but databases do not typically expose convenient
ways to fake time.

In this (admittedly trivial) example, Postgres's `now()` function was initially
set as the default for the `mission_landings.landed_at` column. Because this
value is set by the database as opposed to being passed a SQL query parameter,
merely faking time in Ruby wouldn't be sufficient! We need to fake the
column default's answer to what time "now" is.

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

This repo also contains a demonstration of an alternative approach in a
[shadowing-builtin-now-function](https://github.com/testdouble/time_traveler_demo/tree/shadowing-builtin-now-function)
branch, which shadows the `pg_catalog.now()` function in pre-production
environments, but will call through to the real one (see commit messages for
caveats and risks that might entail).
