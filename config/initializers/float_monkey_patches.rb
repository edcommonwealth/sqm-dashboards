module FloatMonkeyPatches
  def round_up_to_one
    if positive? && self < 1
      1.0
    else
      self
    end
  end

  def round_down_to_five
    if positive? && self > 5
      5.0
    else
      self
    end
  end
end

Float.include FloatMonkeyPatches
