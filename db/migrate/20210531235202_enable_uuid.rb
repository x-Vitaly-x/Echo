#
# Need this to make it possible to work with string uuids for endpoints
# #

class EnableUuid < ActiveRecord::Migration[6.1]
  def change
    enable_extension 'pgcrypto'
  end
end
