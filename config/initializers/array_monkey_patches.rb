module ArrayMonkeyPatches
  def average
    sum.to_f / size
  end

  def remove_zeros
    reject { |item| item == 0 || item.to_f.nan? }
  end
end

Array.include ArrayMonkeyPatches
