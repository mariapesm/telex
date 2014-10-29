def count_selects
  s = StringIO.new
  l = Logger.new(s)
  Sequel::Model.db.loggers << l

  yield

  s.string.split(' ').grep(/SELECT/).count
ensure
  Sequel::Model.db.loggers.delete(l)
end
