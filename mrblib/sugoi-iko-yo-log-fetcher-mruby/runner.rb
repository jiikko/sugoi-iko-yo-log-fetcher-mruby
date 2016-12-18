AWS::S3::S3_ENDPOINT = 's3-ap-northeast-1.amazonaws.com'

module SugoiIkoYoLogFetcherMruby
  class TimeParserList
    def initialize(*dates)
      @dates = dates.map { |x| TimeParser.new(x) }
    end

    def map(&block)
      case @dates.size
      when 1
        @dates.map { |date| yield(date) }
      when 2
        list = [@dates[0]]
        30.times do # 無限ループ防止
          if list.last.to_s == @dates[1].to_s
            break
          else
            list << @dates[0].next_day
          end
        end
        @dates.map { |date| yield(date) }
      else
        puts 'error! no args.'
        exit 1
      end
    end

  end

  class TimeParser
    def initialize(date_string)
      list = date_string.split('-')
      @time = Time.new(list[0].to_i, list[1].to_i, list[2].to_i)
    end

    def to_s
      "#{@time.year}-#{@time.month}-#{@time.day}"
    end

    def to_s_for_dir
      to_s.gsub('-', '/')
    end

    def next_day
      TimeParser.new(self.to_s) + ((60 ** 2) * 24)
    end
  end

  class Runner
    def initialize(dates)
      @dates = TimeParserList.new(dates)
    end

    def download!
      global_download_list = []
      @dates.map do |date|
        oneday_download_list = oneday_dawnload(date)
        global_download_list.concat(oneday_download_list)
      end
      puts "zgrep \"REGEX\" #{global_download_list.join(' ')}"
    end

    # cruby aws-sdkのようにprefixに
    # 一致してダウンロードできないので命名規則で舐める
    def oneday_dawnload(date)
      date_to_s = date.to_s_for_dir
      local_paths = []
      30.times do |index| # 30個以上1日のログが分割されないでしょ
        current_s3_path = s3_path(date_to_s, index)
        puts current_s3_path
        res = s3.download(current_s3_path) # bloking and hungup!!! why!?
        puts 'complate'
        if res.status.to_i == 200
          puts "downloaded #{current_s3_path}"
          current_local_path = local_path(date_to_s, index)
          File.write(current_local_path, res.body)
          local_paths << current_local_path
        else
          break
        end
      end
      local_paths
    end

    def local_path(date_to_s, index)
      file_path = "logs/app/#{date_to_s}_#{index}.gz"
      mkdir_by(file_path)
      file_path
    end

    def mkdir_by(file_path)
      dir_path = file_path.split('/')
      dir_path.pop
      FileUtilsSimple.mkdir_p(File.join(dir_path))
    end

    def s3_path(date_to_s, index)
      "/logs/app/#{date_to_s}_#{index}.gz"
    end

    def s3
      return @s3 if @s3
      home = `echo ~`.chomp
      secrets = File.open("#{home}/.ai_s3log").read.split("\n")
      @s3 = AWS::S3.new(secrets[0], secrets[1])
      @s3.set_bucket(bucket_name)
      @s3
    end

    def bucket_name
       'iko-yo.net'
    end
  end
end
