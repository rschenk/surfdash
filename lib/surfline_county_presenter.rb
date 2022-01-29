class SurflineCountyPresenter < SimpleDelegator
  class Spot < SimpleDelegator
    def conditions_class
      conditions.downcase.gsub(/\W+/, '-')
    end

    def id
      name.downcase.gsub(/\W+/, '-').chomp('-')
    end

    def wave_range
      super.gsub(' ft', '')
    end
  end

  def spots
    super.map { |s| Spot.new(s) }
  end

  def favorite_spots
    favorites = %w[
      cocoa-beach-pier
      lori-wilson-park
      16th-st-south
      2nd-light
      hightower-beach
      indialantic-boardwalk
      ocean-ave
    ]
    spot_map = spots.map { |s| [s.id, s] }.to_h
    favorites.map { |id| spot_map[id] }
  end
end
