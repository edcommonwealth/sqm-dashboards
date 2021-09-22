module ArrayMonkeyPatches
  def average
    self.sum.to_f / self.size
  end
end

Array.include ArrayMonkeyPatches
