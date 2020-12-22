module Util
  module Time
    module_function

    def time_iterate(start_time, end_time, step)
      begin
        yield(start_time)
      end while (start_time += step) < end_time
    end

    def time_slots(start_time, end_time, step)
      slots = []

      time_iterate(start_time, end_time, step) do |t|
        slots << (t..(t+step))
      end
      slots
    end

    # assumption is that both arrays are sorted by starttime asc
    # gives out indices of time_slots_1 array, which overlap with the time_slots_2
    def overlapping_slot_indices(time_slots_1, time_slots_2)
      indices = []

      current_idx = 0
      time_slots_1.each_with_index do |slot, slot_idx|
        while current_idx < time_slots_2.size && slot.first >= time_slots_2[current_idx].last
          current_idx+=1
        end
        break if current_idx == time_slots_2.size

        no_overlap = (time_slots_2[current_idx].first >= slot.last || time_slots_2[current_idx].last <= slot.first)
        indices << slot_idx unless no_overlap
      end
      indices
    end
  end
end