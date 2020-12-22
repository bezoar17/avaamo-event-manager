# spec/requests/events_spec.rb
require 'rails_helper'

# Note `json` is a custom helper to parse JSON responses

RSpec.describe 'Events API', type: :request do
  # initialize test data
  let!(:events) { create_list(:event, 10) }
  let(:event_id) { events.first.id }

  # Test suite for GET /api/v1/events
  describe 'GET /api/v1/events' do
    before { get '/api/v1/events' }

    it 'returns all events' do
      expect(json).not_to be_empty
      expect(json.map{|e| e['id']}).to match_array(events.map(&:id))
    end

    it 'returns status code 200' do
      expect(response).to have_http_status(:success)
    end
  end

  # Test suite for GET /api/v1/events/:id
  describe 'GET /api/v1/events/:id' do
    before { get "/api/v1/events/#{event_id}" }

    context 'when the record exists' do
      it 'returns the event' do
        expect(json).not_to be_empty
        expect(json['id']).to eq(event_id)
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(:success)
      end
    end

    context 'when the record does not exist' do
      let(:event_id) { 100 }

      it 'returns status code 404' do
        expect(response).to have_http_status(:not_found)
      end

      it 'returns a not found message' do
        expect(response.body).to match(/Entity not found/)
      end
    end
  end

  # Test suite for POST /api/v1/events
  describe 'POST /api/v1/events' do
    # valid payload
    let!(:valid_attributes) { { title: 'Learn Elm', starttime: Time.now, endtime: Time.now + 3.hour } }

    context 'when the user is unauthenticated' do
      before { post '/api/v1/events', params: valid_attributes }

      it 'returns status code 401' do
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'when the user is set' do
      let(:user) { create(:user) }
      let(:headers) { {"username" => user.username} }

      context 'when the request is valid' do
        before { post '/api/v1/events', params: valid_attributes, headers: headers }

        it 'returns status code 201' do
          expect(response).to have_http_status(:created)
        end

        it 'creates a event, and event_user, with role: :creator' do
          event_user = EventUser.find_by(event_id: json['id'], user_id: user.id)

          expect(json['title']).to eq('Learn Elm')
          expect(event_user.role.to_sym).to eq(:creator)
        end
      end

      context 'when all day event is set with no endtime' do
        before { post '/api/v1/events', params: valid_attributes.except(:endtime).merge(allday: true), headers: headers }

        it 'returns status code 201' do
          expect(response).to have_http_status(:created)
        end

        it 'creates a event, with proper timestamps' do
          d = valid_attributes[:starttime].to_date.beginning_of_day
          expect(json['starttime']).to eq(d.as_json)
          expect(json['endtime']).to eq(d.end_of_day.as_json)
        end
      end

      context 'when all day event is set with invalid endtime' do
        before { post '/api/v1/events', params: valid_attributes.except(:endtime).merge(allday: true).merge(endtime: Time.now - 3.hour), headers: headers }

        it 'returns status code 201' do
          expect(response).to have_http_status(:created)
        end

        it 'creates a event, with proper timestamps' do
          d = valid_attributes[:starttime].to_date.beginning_of_day
          expect(json['starttime']).to eq(d.as_json)
          expect(json['endtime']).to eq(d.end_of_day.as_json)
        end
      end

      context 'when the request is invalid' do
        context 'when starttime is missing' do
          before { post '/api/v1/events', params: { title: 'Foobar', endtime: Time.now }, headers: headers }

          it 'returns status code 400' do
            expect(response).to have_http_status(:bad_request)
          end

          it 'returns a validation failure message' do
            expect(response.body).to match(/Validation failed: Starttime can't be blank/)
          end
        end

        context 'when endtime is missing for non-all day event' do
          before { post '/api/v1/events', params: { title: 'Foobar', starttime: Time.now }, headers: headers }

          it 'returns status code 400' do
            expect(response).to have_http_status(:bad_request)
          end

          it 'returns a validation failure message' do
            expect(response.body).to match(/Endtime should be present for non all-day event/)
          end
        end

        context 'when endtime is < starttime for non-all day event' do
          before { post '/api/v1/events', params: { title: 'Foobar', starttime: Time.now, endtime: Time.now - 2.hours }, headers: headers }

          it 'returns status code 400' do
            expect(response).to have_http_status(:bad_request)
          end

          it 'returns a validation failure message' do
            expect(response.body).to match(/Endtime should be greater than Starttime/)
          end
        end
      end
    end
  end

  # Test suite for PUT /api/v1/events/:id/users
  describe 'PUT /api/v1/events/:id/users' do
    let(:users) { create_list(:user, 5) }
    let(:user_ids) { users.map(&:id) }

    before { put "/api/v1/events/#{event_id}/users", params: {ids: user_ids }}

    context 'when no older record exists' do
      it 'creates new event_user entries with nil rsvp' do
        event_user = EventUser.where(event_id: event_id, rsvp: nil).count
        expect(event_user).to eq(users.size)
      end

      it 'returns status code 204' do
        expect(response).to have_http_status(:no_content)
      end
    end

    context 'when overlapping user_ids are sent' do
      let(:new_users) { create_list(:user, 3) }
      let(:new_user_ids) { users.map(&:id).first(3) + new_users.map(&:id) }

      before { put "/api/v1/events/#{event_id}/users", params: {ids: new_user_ids }}

      it 'it adds only new users' do
        total_event_user = EventUser.where(event_id: event_id).count
        expect(total_event_user).to eq(users.size + new_users.size)
      end
    end
  end

  # Test suite for GET /api/v1/events/:id/invitees
  context 'GET /api/v1/events/:id/invitees' do
    let(:event) { events.first }

    context 'when no user has been invited yet' do
      before { get "/api/v1/events/#{event.id}/invitees" }

      it 'returns empty array' do
        expect(json).to be_empty
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(:success)
      end
    end

    context 'when users have been invited' do
      let!(:event_users) { create_list(:event_user, 10, event: event) }
      let!(:users) { event.users }

      before { get "/api/v1/events/#{event.id}/invitees" }

      it 'returns status code 200' do
        expect(response).to have_http_status(:success)
      end

      it 'returns all invitees' do
        expect(json).not_to be_empty
        expect(json.map{|e| e['id']}).to match_array(users.map(&:id))
      end
    end
  end

  # Test suite for GET /api/v1/events/:id/rsvps
  context 'GET /api/v1/events/:id/rsvps' do
    let(:event) { events.first }

    context 'when no user has been invited yet' do
      before { get "/api/v1/events/#{event.id}/rsvps" }

      it 'returns empty array' do
        expect(json).to be_empty
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(:success)
      end
    end

    context 'when users have been invited' do
      let!(:event_users) { create_list(:event_user, 5, event: event) }
      let!(:users) { event.users }

      context 'when no one has rsvpd' do
        before { get "/api/v1/events/#{event.id}/rsvps" }

        it 'returns empty array' do
          expect(json).to be_empty
        end

        it 'returns status code 200' do
          expect(response).to have_http_status(:success)
        end
      end

      context 'when some users have rsvpd' do
        let!(:rsvp_event_users) { create_list(:event_user, 5, event: event, rsvp: [:yes, :no, :maybe].sample)}
        let!(:rsvpd_users) { rsvp_event_users.map(&:user) }

        before { get "/api/v1/events/#{event.id}/rsvps" }

        it 'returns status code 200' do
          expect(response).to have_http_status(:success)
        end

        it 'returns all rsvpd entries with proper keys' do
          expect(json).not_to be_empty
          expect(json.map{|e| e['id']}).to match_array(rsvpd_users.map(&:id))
          expect(json.first.keys).to contain_exactly('id', 'username', 'rsvp')
        end
      end
    end
  end

  # Test suite for PUT /api/v1/events/:id/rsvp
  context 'PUT /api/v1/events/:id' do
    let(:event) { events.first }
    let(:user) { create(:user) }

    let(:rsvp_value) { [:yes, :no, :maybe].sample }

    context 'when the user is unauthenticated' do
      before { put "/api/v1/events/#{event.id}/rsvp", params: {value: rsvp_value} }

      it 'returns status code 401' do
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context "when user isn't invited to the event" do
      let(:random_user) { create(:user) }
      let(:headers) { {"username" => random_user.username} }

      before { put "/api/v1/events/#{event.id}/rsvp", params: {value: rsvp_value}, headers: headers }

      it 'returns status code 401' do
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context "when user is invited to the event" do
      let!(:event_user) { create(:event_user, event: event, user: user) }
      let(:headers) { {username: user.username} }

      before { put "/api/v1/events/#{event.id}/rsvp", params: {value: rsvp_value}, headers: headers }

      it "updates the rsvp value" do
        entry = EventUser.find_by(event_id: event.id, user_id: user.id)
        expect(entry.rsvp.to_sym).to eq(rsvp_value)
      end

      it 'returns status code 204' do
        expect(response).to have_http_status(:no_content)
      end
    end

    context "when user rsvps yes to an event which has overlapping events" do
      let!(:subject_rsvp) { create(:event_user, event: event, user: user) }
      let(:headers) { {username: user.username} }

      let!(:overlapping_events) { 3.times.map {
        create(:event, starttime: Faker::Time.between(from: event.starttime, to: event.endtime-1.second))
      }}

      let!(:non_overlapping_events) { 4.times.map { create(:event, starttime: Faker::Time.between(from: event.endtime, to: event.endtime+1.day))
        } << (create(:event, starttime: event.endtime))
      }

      let!(:no_maybe_rsvps) {
        (overlapping_events.last(2) + non_overlapping_events.last(4)).map { |i| create(:event_user, event: i, user: user, rsvp: [:no, :maybe].sample)  }
      }

      context "overlapping yes rsvp events check" do
        let!(:overlapping_yes_rsvp) { create(:event_user, event: overlapping_events.first, user: user, rsvp: :yes) }

        before { put "/api/v1/events/#{event.id}/rsvp", params: {value: :yes}, headers: headers }

        it "updates only the rsvp value for overlapping rsvpd yes event" do
          result = EventUser.find_by(id: overlapping_yes_rsvp.id).rsvp
          expect(result.to_sym).to eq(:no)

          arr = EventUser.where(id: no_maybe_rsvps.map(&:id))
          expect(arr).to match_array(no_maybe_rsvps)
        end

        it 'returns status code 204' do
          expect(response).to have_http_status(:no_content)
        end
      end

      context "non-overlapping yes rsvp check" do
        let!(:non_overlapping_yes_rsvp) { create(:event_user, event: non_overlapping_events.first, user: user, rsvp: :yes) }

        before { put "/api/v1/events/#{event.id}/rsvp", params: {value: :yes}, headers: headers }

        it "does not update any other entry" do
          arr = no_maybe_rsvps + [non_overlapping_yes_rsvp]
          expect(EventUser.where(id: arr.map(&:id))).to match_array(arr)
        end

        it 'returns status code 204' do
          expect(response).to have_http_status(:no_content)
        end
      end
    end
  end
end
