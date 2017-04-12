module SchedulesHelper

  def options_for_frequency_hours
    [
      ['Once A Day', 24],
      ['Once A Week', 24 * 7],
      ['Every Other Week', 2 * 24 * 7],
      ['Once A Month', 4 * 24 * 7]
    ]
  end

  def frequency_description(hours)
    case hours
    when (24 * 7)
      'Once A Week'
    when (2 * 24 * 7)
      'Every Other Week'
    when (4 * 24 * 7)
      'Once A Month'
    end
  end
end
