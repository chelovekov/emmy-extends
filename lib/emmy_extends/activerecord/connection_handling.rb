module EmmyExtends
  module ConnectionHandling
    def self.emmy_mysql2_connection(config)
      client = ConnectionPool.new(size: config[:pool]) do
        conn = ActiveRecord::ConnectionAdapters::EMMysql2Adapter::Client.new(config.symbolize_keys)
        # From Mysql2Adapter#configure_connection
        conn.query_options.merge!(:as => :array)

        # By default, MySQL 'where id is null' selects the last inserted id.
        # Turn this off. http://dev.rubyonrails.org/ticket/6778
        variable_assignments = ['SQL_AUTO_IS_NULL=0']
        encoding = config[:encoding]
        variable_assignments << "NAMES '#{encoding}'" if encoding

        wait_timeout = config[:wait_timeout]
        wait_timeout = 2592000 unless wait_timeout.is_a?(Fixnum)
        variable_assignments << "@@wait_timeout = #{wait_timeout}"

        conn.query("SET #{variable_assignments.join(', ')}")
        conn
      end
      options = [config[:host], config[:username], config[:password], config[:database], config[:port], config[:socket], 0]
      Adapter.new(client, logger, options, config)
    end
  end
end
