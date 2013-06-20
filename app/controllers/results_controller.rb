class ResultsController < ApplicationController
   # show the page details for the specified work
   #
   def show
      @work_id = params[:work]
      @batch_id = params[:batch]
      work = Work.find(@work_id)
      @work_title=work.wks_title
      
      if !@batch_id.nil?
         batch = BatchJob.find(@batch_id)
         @batch = "#{batch.id}: #{batch.name}"
      else 
         @batch = "Not Applicable"   
      end
   end

   # Fetch data for dataTable
   #
   def fetch
      puts params
      
      work_id = params[:work]
      batch_id = params[:batch]
      if batch_id.nil? || batch_id.length == 0
         render_page_info(work_id)
      else
         render_batch_results(work_id, batch_id)
      end
   end
   
   # Render pages table without batch results
   #
   def render_page_info(work_id)
      resp = {}
      resp['sEcho'] = params[:sEcho]
      
      sql = ["select count(*) as cnt from pages where pg_work_id=?"]
      sql = sql << work_id
      cnt = PageResult.find_by_sql(sql).first.cnt
      resp['iTotalRecords'] = cnt
      resp['iTotalDisplayRecords'] = resp['iTotalRecords']
     
      # only order by page number here.. thats all thats available
      dir = params[:sSortDir_0]
      dir = "asc" if dir.nil?
      order_col = "pg_ref_number"
      
      sql = ["select pg_ref_number as page_num, pg_page_id as page_id from pages where pg_work_id=?", work_id]
      pages = Page.find_by_sql(sql)
      
      # get results and transform them into req'd json structure
      data = []
      pages.each do | page |
         rec = {}
         rec[:page_select] = "<input class='sel-cb' type='checkbox' id='sel-page-#{page.page_id}'>"
         rec[:detail_link] = "<div class='detail-link disabled'>"  # no details yet!
         rec[:status] = "<div class='status-icon idle' title='Untested'></div>"
         rec[:page_number] = page.page_num
         rec[:juxta_accuracy] = "-"
         rec[:retas_accuracy] = "-"
         rec[:page_image] = "<a href=\"/results/#{work_id}/page/#{page.page_num}\"><div title='View page image' class='page-view'></div></a>"

         data << rec
      end
      
      resp['data'] = data
      render :json => resp, :status => :ok    
   end
   
   # Render the pages table including batch results
   #
   def render_batch_results(work_id, batch_id)
      resp = {}
      resp['sEcho'] = params[:sEcho]
      
      sql = ["select count(*) as cnt from page_results inner join pages on page_id=pg_page_id where batch_id=? and pg_work_id=?"]
      sql = sql << batch_id
      sql = sql << work_id
      resp['iTotalRecords'] = PageResult.find_by_sql(sql).first.cnt
      resp['iTotalDisplayRecords'] = resp['iTotalRecords']
     
      # generate order info based on params
      search_col_idx = params[:iSortCol_0].to_i
      cols = [nil,'pg_ref_number','page_results.juxta_change_index','page_results.alt_change_index']
      dir = params[:sSortDir_0]
      dir = "asc" if dir.nil?
      order_col = cols[search_col_idx]
      order_col = cols[1] if order_col.nil?
      
      # get results and transform them into req'd json structure
      data = []
      sel =  "select pages.pg_ref_number as page_num,pages.pg_page_id as page_id,"
      sel << " page_results.id as result_id, page_results.juxta_change_index as juxta, page_results.alt_change_index as retas, job_status"
      from =  "FROM pages"
      from << " INNER JOIN page_results ON page_results.page_id = pages.pg_page_id"
      from << " INNER JOIN job_queue ON page_results.page_id = job_queue.page_id and page_results.batch_id = job_queue.batch_id"
      cond = "where page_results.batch_id=? and pg_work_id=?"
      order = "order by #{order_col} #{dir}"
      sql = ["#{sel} #{from} #{cond} #{order}", batch_id, work_id]
      pages = Page.find_by_sql( sql )
      msg = "View side-by-side comparison with GT"
      pages.each do | page | 
         rec = {}
         rec[:page_select] = "<input class='sel-cb' type='checkbox' id='sel-page-#{page.page_id}'>"
         rec[:detail_link] = "<a href='/juxta?work=#{work_id}&batch=#{batch_id}&page=#{page.page_num}&result=#{ page.result_id}' title='#{msg}'><div class='detail-link'></div></a>"
         rec[:status] = get_status_icon(page.job_status.to_i)
         rec[:page_number] = page.page_num
         rec[:juxta_accuracy] = page.juxta
         rec[:retas_accuracy] = page.retas
         rec[:page_image] = "<a href=\"/results/#{work_id}/page/#{page.page_num}\"><div title='View page image' class='page-view'></div></a>"

         data << rec
      end
      
      resp['data'] = data
      render :json => resp, :status => :ok
   end
   
   def get_page_image
      work_id = params[:work]
      page_num = params[:num]   
      work = Work.find(work_id)
      img_path = get_ocr_image_path(work, page_num)
      send_file img_path, type: "image/tiff", :stream => true, disposition: "inline"
   end
   
   private
   def get_status_icon( job_status )
      status = "idle"
      msg = "Untested"
      if job_status ==1 || job_status ==2
         status = "scheduled"
         msg = "OCR jobs are scheduled"  
      elsif job_status==6
         status = "error"
         msg = "OCR jobs have failed"
      elsif job_status > 2 && job_status < 6
         status = "success"
         msg = "Success"
      end
      return "<div class='status-icon #{status}' title='#{msg}'></div>"
   end
   
   private
   def get_ocr_image_path(work, page_num) 
      if work.isECCO?
         # ECCO format: ECCO number + 4 digit page + 0.tif
         ecco_dir = work.wks_ecco_directory
         return "%s%s/images/%s%04d0.TIF" % [Settings.emop_path_prefix, ecco_dir, work.wks_ecco_number, page_num];
      else
         # EEBO format: 00014.000.001.tif where 00014 is the page number.
         ebbo_dir = work.wks_eebo_directory
         return "%s%s/%05d.000.001.tif", [Settings.emop_path_prefix, ebbo_dir, page_num];
      end
   end

end
