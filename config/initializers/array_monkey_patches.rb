# frozen_string_literal: true

module ArrayMonkeyPatches
  def average
    sum.to_f / size
  end

  def remove_blanks
    reject { |item| item.nil? || item.to_f.nan? || item.zero? }
  end
end

Array.include ArrayMonkeyPatches
