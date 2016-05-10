class HomeController < ApplicationController
  def index
    univs = Univ.where("name LIKE ?", "%#{params[:univ]}%").pluck(:id)
    celebs = Celeb.where("name LIKE ?", "%#{params[:celeb]}%").pluck(:id)
    logger.debug("=========CELEB========")
    logger.debug(params[:celeb])

    # select keyword
    Keyword.where("name LIKE ?", "#{params[:keyword]}")

    # select date
    if (params[:from].nil? || params[:from] == "") && (params[:to].nil? || params[:to] == "")
      schedules = Schedule.all
    elsif params[:from].nil? || params[:from] == ""
      date = get_date(params[:to])
      schedules = Schedule.all.select { |m| m.date <= date }
    elsif params[:to].nil? || params[:to] == ""
      date = get_date(params[:from])
      schedules = Schedule.all.select { |m| m.date >= date }
    else
      from_date = get_date(params[:from])
      to_date = get_date(params[:to])
      schedules = Schedule.all.select { |m| m.date >= from_date && m.date <= to_date }
    end



    # select univ
    tmp_festivals = []
    schedules.each do |s|
      tmp_festivals += s.festivals.where(univ_id: univs)
    end

    tmp_festivals.uniq!

    if params[:celeb].nil? || params[:celeb] == ""
      festivals = tmp_festivals
    else
      # select celeb
      festivals = []
      tmp_festivals.each do |f|
        status = false
        f.festival_schedules.each do |fs|
          fsc = fs.celebs.pluck(:id).count
          arr = fs.celebs.pluck(:id) - celebs
          if arr.count != fsc
            status = true; break;
          end
        end
        festivals << f if status == true
      end
    end


    @fs = Kaminari.paginate_array(festivals).page(params[:page]).per(7)

  end

  def search
    univs = Univ.where("name LIKE ?", "%#{params[:univ]}%").pluck(:id)
    celebs = Celeb.where("name LIKE ?", "%#{params[:celeb]}%").pluck(:id)
    logger.debug("=========CELEB========")
    logger.debug(params[:celeb])

    # select keyword
    Keyword.where("name LIKE ?", "#{params[:keyword]}")

    # select date
    if (params[:from].nil? || params[:from] == "") && (params[:to].nil? || params[:to] == "")
      schedules = Schedule.all
    elsif params[:from].nil? || params[:from] == ""
      date = get_date(params[:to])
      schedules = Schedule.all.select { |m| m.date <= date }
    elsif params[:to].nil? || params[:to] == ""
      date = get_date(params[:from])
      schedules = Schedule.all.select { |m| m.date >= date }
    else
      from_date = get_date(params[:from])
      to_date = get_date(params[:to])
      schedules = Schedule.all.select { |m| m.date >= from_date && m.date <= to_date }
    end



    # select univ
    tmp_festivals = []
    schedules.each do |s|
      tmp_festivals += s.festivals.where(univ_id: univs)
    end

    tmp_festivals.uniq!

    if params[:celeb].nil? || params[:celeb] == ""
      festivals = tmp_festivals
    else
      # select celeb
      festivals = []
      tmp_festivals.each do |f|
        status = false
        f.festival_schedules.each do |fs|
          fsc = fs.celebs.pluck(:id).count
          arr = fs.celebs.pluck(:id) - celebs
          if arr.count != fsc
            status = true; break;
          end
        end
        festivals << f if status == true
      end
    end


    @fs = Kaminari.paginate_array(festivals).page(params[:page]).per(7)

    respond_to do |format|
      format.js
      format.html { render '/home/index' }
    end
  end

  def detail
    @f = Festival.find(params[:id])
  end

  def get_name

    respond_to do |format|
      format.json{
        render json: {
            result: true,
            univs: Univ.all.pluck(:name),
            celebs: Celeb.all.pluck(:name)
        }
      }
    end
  end

  def add_search
    search = Search.new
    search.univ = params[:univ]
    search.from = params[:from]
    search.to = params[:to]
    search.celeb = params[:celeb]
    search.keyword = params[:keyword]

    search.save

    respond_to do |format|
      format.json{
        render json: {
            result: true
        }
      }
    end
  end

  private
  def get_date date
    date_arr = date.split('/')
    date_arr.map! { |a| a.to_i }
    return DateTime.new(date_arr[0],date_arr[1],date_arr[2])
  end

end
