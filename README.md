# AVAAMO EVENT MANAGER

**Problem Statement** [PDF](https://github.com/bezoar17/avaamo-event-manager/blob/main/Event%20Manager%20(Iteration%201).pdf)

## Setup
```
This app uses ruby 2.5, rails 6 (api only mode), Postgres 11.9, rpsec 4.0 and is setup using docker
```

Steps to run the app in a new machine
* install docker-compose
* clone the repository
* from the repo's directory, run `docker-compose up`
* in a new terminal tab
    * run `docker-compose exec web /bin/bash`
    * run  `rails db:create db:migrate db:seed`

Once this initial setup is done, in subsequent runs, just run `docker-compose up` to get the app running

The app is accessible at `localhost:3000`

## Assumptions/ notes
  - rails API only mode has been used, which is a striped down version of rails for APIs
  - things like cors prevention, user authentication etc. have not been implemented
  - username, email, phone-number are assumed to be case-insensitively unique
  - events, are not unique by any parameter
  - while seeding
    - it skips invalid events (end_time < start_time)
    - for overlapping rsvpd yes events for a user, it tries to maintain rsvp yes for maximum events
  - start, end date ranges whenever sent as parameter, consider end_date as inclusive, so to get events for 3/10/2020 both start and end date should be 3/10/2020
  - similarly, if start_date is 3/10/2020 and end_date is 4/10/2020, events within 2020/10/03 12:00 AM - 2020/10/04 11:59 PM will be considered. So an event like [ 2020/10/04 11:30 PM, 2020/10/05 00:30 AM ] will be considered in this range
  - following this, and event like [23:30 - 01:30] will render the 0-2 AM slot for next day as unavailable
  - [3-4] and [4-5], these 2 are not considered overlapping events
  - event has 1 creator(if created through api), and is invited by default, but not rsvpd by default
  - any user can add any user to an event

## Routes
| Verb | URI Pattern | Controller#Action |
| ------ | ------ | ------ |
| GET  | /api/v1/users                  | api/v1/users#index |
| GET  | /api/v1/users/:id              | api/v1/users#show |
| GET  | /api/v1/users/:id/events       | api/v1/users#events |
| GET  | /api/v1/users/:id/availability | api/v1/users#availability |
| POST | /api/v1/users                  | api/v1/users#create |
| GET  | /api/v1/events                 | api/v1/events#index |
| GET  | /api/v1/events/:id             | api/v1/events#show |
| GET  | /api/v1/events/:id/invitees    | api/v1/events#invitees |
| GET  | /api/v1/events/:id/rsvps       | api/v1/events#rsvps |
| PUT  | /api/v1/events/:id/users       | api/v1/events#users |
| PUT  | /api/v1/events/:id/rsvp        | api/v1/events#rsvp |
| POST | /api/v1/events                 | api/v1/events#create |

## API definition
### User actions

* `GET  /api/v1/users`
  `Get the list of users in the system`

* `GET  /api/v1/users/:id`
  `Get user for the given id, raise 404 if user is not present`

* `GET  /api/v1/users/:id/events?start_date&=end_date=`

  `List all events user has been invited to. Sending start_date and end_date will filter events based on these dates`

* `GET  /api/v1/users/:id/availability?start_date=&end_date=&slot_size=`

  `List user availability in blocks of slot_size(in seconds) param. start_date, end_date are required params, slot_size is optional whose default value is 7200.`

* `POST  /api/v1/users/`
  `Create a user with the given parameters. username, email and phone-no all 3 are required`

### Event action

* `GET  /api/v1/events`
  `List all registered events`

* `GET  /api/v1/events/:id`
  `Get event for the given id, raise 404 if event is not present`

* `GET  /api/v1/events/:id/invitees`
  `Get all users invited to an event`

* `GET  /api/v1/events/:id/rsvps`
  `Get all users invited to an event, who have rsvpd(any value)`

* `PUT  /api/v1/events/:id/users?ids[]=&ids[]=`

  `Takes ids(array of user_ids) as a parameter. Invites all uninvited users to the event. This endpoint only invites users if they were uninvited, it does not remove any invited user whose id is not in the parameter`

* `PUT  /api/v1/events/:id/rsvp`
  `Rsvp to an event by id. Action performed for the current_user.`

* `POST  /api/v1/events/`
  `Create an event with given parameters. Throws error for invalid params`