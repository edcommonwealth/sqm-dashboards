module ArrayMonkeyPatches
  def average
    sum.to_f / size
  end
end

Array.include ArrayMonkeyPatches
