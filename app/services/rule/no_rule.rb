module Rule
  class NoRule
    def initialize(row:); end

    def skip_row?
      false
    end
  end
end
