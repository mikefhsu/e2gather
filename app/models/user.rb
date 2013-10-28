class User < ActiveRecord::Base
self.primary_key='user_id'
has_many :ingredients, dependent: :destroy
has_many :events, dependent: :destroy

def add_ingredient(new_ingredient)
  if @ingredients.nil?
    @ingredients = Array.new
  end
  @ingredients << new_ingredient
end

def delete_ingredient(ingred_id)
  unless @ingredients.nil? or @ingredents.length == 0
    @ingredients.each { |tmp|
      if tmp.get_id() == ingred_id
        @ingredients.delete(tmp)
        return
      end
    }
  end
end

def update_ingredient(ingred_id, quant)
    unless @ingredients.nil? or @ingredients.length == 0
      @ingredeints.each { |tmp|
        if tmp.get_id() == ingred_id
          diff = tmp.get_quant() - quant
          if diff < 0
            tmp.set_quant(0)
          else
            tmp.set_quant(diff)
          end
        end
      }
    end
end

def create_event(name, location, date, ingredients, guests)
  if @events.nil?
    @events = Array.new
  end

  Event e = Event.new
  e.set_host(self.name)
  e.set_name(name)
  e.set_location(location)
  e.set_date(date)
  e.set_ingredients(ingredients)
  e.set_guests(guests)

  e.save
  @events << e
end

def update_event(event_id, acc_del)
  #Combine accept_event and decline_event
  #Need a method update_guest(user) in Event
  unless @ingredients.nil? or @ingredients.length == 0
    @ingredients.each { |tmp|
      if tmp.get_id() == event_id
        tmp.update_guest(self, acc_del)
        return
      end
    }
  end
end

def get_events
  unless @events.nil?
    return @events
  end
end

end
