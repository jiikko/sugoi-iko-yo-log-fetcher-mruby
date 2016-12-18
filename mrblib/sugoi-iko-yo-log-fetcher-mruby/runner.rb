AWS::S3::S3_ENDPOINT = 's3-us-west-2.amazonaws.com'

module SugoiIkoYoLogFetcherMruby
  class TimeParserList
    def initialize(*dates)
      @dates = dates.map { |x| TimeParser.new(x) }
    end

    def map
      case @dates.size
      when 1
        [@dates.first]
      when 2
        list = [@dates[0]]
        30.times do # 無限ループ防止
          if list.last.to_s == @dates[1].to_s
            break
          else
            list << @dates[0].next_day
          end
        end
        list
      else
        puts 'error! no args.'
        exit 1
      end
    end

  end

  class TimeParser
    def initialize(date_string)
      list = date_string.split(/-/)
      @time = Timw.new(list[0], list[1], list[2])
    end

    def to_s
      "#{@time.year}-#{@time.month}-#{@time.day}"
    end

    def next_day
      TimeParser.new(self.to_s) + ((60 ** 2) * 24)
    end
  end

  class Runner
    def initialize(*dates)
      @dates = TimeParserList.new(dates)
    end

    def download!
      global_download_list = []
      @dates.map do |date|
        oneday_download_list = oneday_dawnload(date)
        global_download_list.concat(oneday_download_list)
      end
      puts "zgrep #{global_download_list.join(' ')}"
    end

    # cruby aws-sdkのようにprefixに
    # 一致してダウンロードできないので命名規則で舐める
    def oneday_dawnload(date)
      date_to_s = date.to_s
      30.times do |index| # 30個以上1日のログが分割されないでしょ
        res = s3.download(s3_path(date_to_s, index))
        if res.status.to_i == 200
          puts "downloaded #{s3_path(date_to_s, index)}"
          File.write(local_path(date_to_s, index))
        else
          break
        end
      end
    end

    def local_path(date_to_s, index)
      "logs/#{date_to_s}_#{index}.gz"
    end

    def s3_path(date_to_s, index)
      "app/log#{date_to_s}_#{index}.gz"
    end

    def s3
      return @s3 if @s3
      home = `echo ~`.chomp
      secrets = File.open("#{home}/.ai_s3log").read.split("\n")
      @s3 = AWS::S3.new(secrets[0], secrets[1])
      @s3.set_bucket(bucket)
      @s3
    end

    def bucket
       "yjiikko.github.com"
    end
  end
end
