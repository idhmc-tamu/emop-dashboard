module Api
  module V1
    class WorksController < V1::BaseController

      api :GET, '/works', 'List works'
      param_group :pagination, V1::BaseController
      param :is_eebo, :boolean, desc: 'Filter by EEBO Works'
      param :is_ecco, :boolean, desc: 'Filter by ECCO Works'
      def index
        @works = Work.page(paginate_params[:page_num]).per(paginate_params[:per_page])
        if query_params.key?(:is_ecco) && query_params[:is_ecco].to_bool
          @works = @works.is_ecco
        end
        if query_params.key?(:is_eebo) && query_params[:is_eebo].to_bool
          @works = @works.is_eebo
        end

        respond_with @works
      end

      api :GET, '/works/:id', 'Show a work'
      param :id, Integer, desc: 'Work ID', required: true
      def show
        super
      end

      api :PUT, '/works/:id', 'Update a work'
      param :work, Hash, required: true do
        param :wks_gt_number, String
        param :wks_estc_number, String
        param :wks_coll_name, String
        param :wks_tcp_bibno, Integer
        param :wks_marc_record, String
        param :wks_eebo_citation_id, Integer
        param :wks_doc_directory, String
        param :wks_ecco_number, String
        param :wks_book_id, String
        param :wks_author, String
        param :wks_printer, String
        param :wks_word_count, Integer
        param :wks_title, String
        param :wks_eebo_image_id, String
        param :wks_eebo_url, String
        param :wks_pub_date, String
        param :wks_ecco_uncorrected_gale_ocr_path, String
        param :wks_corrected_xml_path, String
        param :wks_corrected_text_path, String
        param :wks_ecco_directory, String
        param :wks_ecco_gale_ocr_xml_path, String
        param :wks_organizational_unit, Integer
        param :wks_primary_print_font, Integer
        param :wks_last_trawled, String
      end
      def update
        super
      end

      private

      def work_params
        params.require(:work).permit(:wks_gt_number, :wks_estc_number, :wks_coll_name, :wks_tcp_bibno, :wks_marc_record, :wks_eebo_citation_id, :wks_doc_directory,
          :wks_ecco_number, :wks_book_id, :wks_author, :wks_printer, :wks_word_count, :wks_title, :wks_eebo_image_id, :wks_eebo_url, :wks_pub_date,
          :wks_ecco_uncorrected_gale_ocr_path, :wks_corrected_xml_path, :wks_corrected_text_path, :wks_ecco_directory, :wks_ecco_gale_ocr_xml_path,
          :wks_organizational_unit, :wks_primary_print_font, :wks_last_trawled)
      end

      def query_params
        params.permit(:is_eebo, :is_ecco)
      end

    end
  end
end
