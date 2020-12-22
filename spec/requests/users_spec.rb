# spec/requests/users_spec.rb
require 'rails_helper'

RSpec.describe 'Users API', type: :request do

  let!(:users) { create_list(:user, 10) }
  let(:user_id) { users.first.id }

  # Test suite for GET /users
  describe 'GET /users' do
    # make HTTP get request before each example
    before { get '/api/v1/users' }

    it 'returns all users' do
      expect(json).not_to be_empty
      expect(json.map{|u| u['id']}).to match_array(users.map(&:id))
    end

    it 'returns status code 200' do
      expect(response).to have_http_status(:success)
    end
  end

  # Test suite for GET /api/v1/users/:id
  describe 'GET /api/v1/users/:id' do
    before { get "/api/v1/users/#{user_id}" }

    context 'when the record exists' do
      it 'returns the user' do
        expect(json).not_to be_empty
        expect(json['id']).to eq(user_id)
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(:success)
      end
    end

    context 'when the record does not exist' do
      let(:user_id) { 100 }

      it 'returns status code 404' do
        expect(response).to have_http_status(:not_found)
      end

      it 'returns a not found message' do
        expect(response.body).to match(/Entity not found/)
      end
    end
  end

  # Test suite for POST /api/v1/users
  describe 'POST /api/v1/users' do
    # valid payload
    let(:valid_attributes) { {username: 'dummy_name', email: 'dummy@check.com', phone: "+91-9876543210" } }

    before { post '/api/v1/users', params: valid_attributes, headers: headers }

    context 'when the request is valid' do

      it 'returns status code 201' do
        expect(response).to have_http_status(:created)
      end

      it 'creates the user' do
        expect(json['username']).to eq('dummy_name')
      end
    end
  end

  # Test suite for GET /api/v1/users/:id/events
  context 'GET /api/v1/users/:id/events' do
    let(:user) { users.first }
    let(:params) { {start_date: Date.today, end_date: Date.today + 2 } }

    # some events starting today, including edge case, when event starts just at end_of_day
    let(:events_for_today) { 3.times.map { create(:event, starttime: Faker::Time.forward(days: 0)) } << create(:event, starttime: (Date.today.end_of_day-1.second)) }
    let(:faraway_events) { 3.times.map { create(:event, starttime: Faker::Time.between_dates(from: Date.today + 3, to: Date.today + 3)) } }

    # invite user to all events
    let!(:event_users) { (events_for_today + faraway_events).map { |e| create(:event_user, user: user, event: e) } }

    context 'when date range is not sent in params' do
      before { get "/api/v1/users/#{user.id}/events" }

      it 'returns all events user has been invited to' do
        expect(json.map { |e| e['id'] }).to match_array((events_for_today + faraway_events).map(&:id))
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(:success)
      end
    end

    context 'when start_date is sent' do
      before { get "/api/v1/users/#{user.id}/events", params: {start_date: Date.today + 3} }

      it 'returns all events starting from start_date' do
        expect(json.map { |e| e['id'] }).to match_array(faraway_events.map(&:id))
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(:success)
      end
    end

    context 'when start_date and end_date is sent' do
      before { get "/api/v1/users/#{user.id}/events", params: params }

      it 'returns all events in the range' do
        expect(json.map { |e| e['id'] }).to match_array(events_for_today.map(&:id))
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(:success)
      end
    end
  end

  # Test suite for GET /api/v1/users/:id/availability
  context 'GET /api/v1/users/:id/availability' do
    let(:user) { users.first }
    let(:slot_size) { AppConstant::Defaults::DEFAULT_INTERVAL }
    let(:params) { {start_date: Date.today, end_date: Date.today, slot_size: slot_size } }

    context 'when no dates are not sent in params' do
      before { get "/api/v1/users/#{user.id}/availability" }

      it 'returns status code 400' do
        expect(response).to have_http_status(:bad_request)
      end

      it 'returns a validation failure message' do
        expect(response.body).to match(/complete date range required/)
      end
    end

    context 'when end_date is not sent in params' do
      before { get "/api/v1/users/#{user.id}/availability", params: params.except(:end_date) }

      it 'returns status code 400' do
        expect(response).to have_http_status(:bad_request)
      end

      it 'returns a validation failure message' do
        expect(response.body).to match(/complete date range required/)
      end
    end

    context 'when start_date is not sent in params' do
      before { get "/api/v1/users/#{user.id}/availability", params: params.except(:start_date) }

      it 'returns status code 400' do
        expect(response).to have_http_status(:bad_request)
      end

      it 'returns a validation failure message' do
        expect(response.body).to match(/complete date range required/)
      end
    end

    context 'when date range is sent' do
      let(:events_for_today) { 7.times.map { create(:event, starttime: Faker::Time.forward(days: 0)) } }
      let(:rsvp_yes_events) { # these are non-overlapping, and cover all edge cases
        [
          create(:event, starttime: Date.today.to_time - 20.minutes , endtime: Date.today.to_time + 30.minutes),
          create(:event, starttime: Date.today.to_time + 4.hour , endtime: Date.today.to_time + 5.hour ),
          create(:event, starttime: Date.today.to_time + 5.hour + 30.minutes, endtime: Date.today.to_time + 7.hour+30.minutes),
          create(:event, starttime: Date.today.to_time + 10.hour, endtime: Date.today.to_time + 12.hour),
          create(:event, starttime: Date.today.to_time + 13.hour, endtime: Date.today.to_time + 18.hour),
          create(:event, starttime: Date.today.to_time + 23.hour + 30.minutes, endtime: Date.today.to_time + 25.hour )
        ]
      }

      # invite user to all events
      before do
       events_for_today.each { |e| create(:event_user, user: user, event: e, rsvp: [:no, :maybe, nil].sample) }
       rsvp_yes_events.each { |e| create(:event_user, user: user, event: e, rsvp: :yes) }
      end

      before { get "/api/v1/users/#{user.id}/availability", params: params }

      it 'returns all slots with correct availability' do
        availability = [
          false,  # 00-02,
          true,  # 02-04,
          false,  # 04-06,
          false,  # 06-08,
          true,  # 08-10,
          false,  # 10-12,
          false,  # 12-14,
          false,  # 14-16,
          false,  # 16-18,
          true,  # 18-20,
          true,  # 20-22,
          false  # 22-24
        ]

        slots = ::Util::Time.time_slots(Date.today.to_time, Date.today.end_of_day, slot_size.seconds)
        availability = availability.zip(slots).map {|a, s| {"available"=> a, "time_range"=> {"start"=> s.first, "end"=> s.last}} }

        json.each { |elem| elem['time_range'].transform_values{|v| DateTime.parse(v)} }
        expect(json).to match_array(availability)
      end

      it 'has proper keys' do
        expect(json.map(&:keys).uniq.first).to match_array(['time_range', 'available'])
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(:success)
      end
    end
  end
end