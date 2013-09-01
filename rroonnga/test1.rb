require 'bundler'
Bundler.require

Groonga::Context.default_options = {:encoding => :utf8}

module GrManager

  def self.setup (db_dir, db_filename)
    @db_dir = db_dir
    @db_filename = db_filename
    @db_fullpath = "#{db_dir}#{db_filename}"
    unless Dir.exist? @db_dir
      Dir.mkdir @db_dir
    end
    begin
      @db = Groonga::Database.create :path => @db_fullpath
    rescue Groonga::FileExists
      @db = Groonga::Database.open @db_fullpath
    end
  end

  def self.destroy
    @db.close
    Dir.chdir @db_dir
    Dir.glob('*').each do |file|
      File.delete file
    end
    Dir.rmdir @db_dir
    true
  end

  class EntryTable
    attr_accessor :table_raw

    @@table_name = 'entries'

    def initialize
      @table_raw = Groonga[@@table_name]
      unless @table_raw
        @table_raw = create_table
      end
    end

    private 

    def create_table
      options = {
        :type => :hash
      }
      Groonga::Schema.create_table('entries', options) do |table|
        table.short_text 'title'
        table.text 'body'
        table.time 'timestamp'
      end
      Groonga[@@table_name]
    end

  end
  
end

