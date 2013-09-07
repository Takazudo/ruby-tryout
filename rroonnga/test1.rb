require 'bundler'
Bundler.require

Groonga::Context.default_options = { encoding: :utf8 }

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
    # return to my directory because current dir will be removed.
    Dir.chdir(File.dirname(__FILE__))
    Dir.rmdir @db_dir
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

    def add entry_id, data
      data[:timestamp] = Time.now
      id = entry_id.to_s
      if record_exist id
        return false
      end
      @table_raw.add id, data
      true
    end

    def record_exist entry_id
      id = entry_id.to_s
      (@table_raw.has_key? id) ? true : false
    end
  
    def size
      @table_raw.size
    end

    def find_by_id entry_id
      id = entry_id.to_s
      @table_raw[id] or nil
    end

    def update_record entry_id, data
      record = find_by_id entry_id
      if record.nil?
        return false
      end
      record.title = data[:title]
      record.body = data[:body]
      record.timestamp = Time.now
      true
    end

    def delete entry_id
      id = entry_id.to_s
      record = find_by_id id
      if record.nil?
        return false
      end
      record.delete
      true
    end

    private 

    def create_table
      options = { type: :hash }
      Groonga::Schema.create_table('entries', options) do |table|
        table.short_text 'title'
        table.text 'body'
        table.time 'timestamp'
      end
      Groonga[@@table_name]
    end

  end
  
end

