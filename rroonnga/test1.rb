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

  class TermTable
    attr_accessor :table_raw

    @@table_name = 'terms'
    
    def initialize
      @table_raw = Groonga[@@table_name]
      unless @table_raw
        @table_raw = create_table
      end
    end

    private

    def create_table
      options = {
        :type => :patricia_trie,
        :normalizer => :NormalizerAuto,
        :default_tokenizer => 'TokenBigram'
      }
      Groonga::Schema.create_table(@@table_name, options) do |table|
        table.index 'entries.title'
        table.index 'entries.body'
      end
    end
  end

  class SearchResult
    
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

    def search keywords
      ret = {}
      ret[:keywords] = keywords
      results = exec_rroonga_search keywords
      ret[:results] = normalize_rroonga_search_results results
      ret
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

    def exec_rroonga_search keywords
      # split by space
      words = keywords.split

      # refered:
      # http://ranguba.org/rroonga/en/Groonga/Table.html#select-instance_method
      # http://magazine.rubyist.net/?0031-RuremaSearch
      # http://www.clear-code.com/blog/2009/7/31.html
      
      # iterate for each records
      results = @table_raw.select do |record|
        expression = nil # result for this record
        words.each do |word|
          sub_expression = nil
          # create target expression object
          target = record.match_target do |match_record|
            (match_record.title * 100) | match_record.body
          end
          # then do the searching
          sub_expression = target =~ word
          # add for next word
          if expression
            expression &= sub_expression
          else
            expression = sub_expression
          end
        end
        expression
      end

      results
    end

    def normalize_rroonga_search_results rroonga_serach_results

      ret = []

      # create snippets
      # http://ranguba.org/rroonga/en/Groonga/Expression.html#snippet-instance_method
      tags = [['<em class="matched">', '</em>']]
      snippet = rroonga_serach_results.expression.snippet(tags)

      rroonga_serach_results.each do |record|

        # KOKOKARA

        current = {}

        # 1. `record` is a object which contains search result info.
        # For example, { score: 1 }
        # 2. `record.key` is the object which was matched with search expression.
        # For example, { title: 'title1!', body: 'body1!' }
        # 3. `record.key.key` is the key of 2.
        # For example, 1.
        #
        # Then, following code works to get the entry_id of the searched result.
        current[:entry_id] = record.key.key

        # tagged title
        title = nil
        snippet.execute(record[:title]).each do |snippet|
          title = snippet
        end
        if title.nil?
          title = record[:title]
        end
        current[:title] = title

        # tagged body
        body = []
        snippet.execute(record[:body]).each do |snippet|
          body.push "#{snippet}..."
        end
        if body.empty?
          body.push record[:body]
        end
        current[:body] = body

        ret.push current

      end

      ret

    end

  end

end

