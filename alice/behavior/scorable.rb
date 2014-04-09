module Alice

  module Behavior
  
    module Scorable

      def check_score
        score_text = "#{self.proper_name} has #{self.points} points"
        score_text << " and is in #{Alice::Util::Sanitizer.ordinal(rank)} place" if rank && rank < 5
        score_text << "."
        score_text
      end

      def score_point
        self.update_attribute(:points, self.points + 1)
      end

      def penalize
        return if self.score == 0
        self.update_attribute(:points, self.points - 1)
      end

      def rank
        places = (Alice::User.where(:points.gt => 0) + Alice::Actor.where(:points.gt => 0)).sort_by(&:points).reverse
        places.present? && places.index(self) + 1
      end

    end

  end

end