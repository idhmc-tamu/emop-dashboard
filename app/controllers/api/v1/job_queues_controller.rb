module Api
  module V1
    class JobQueuesController < V1::BaseController

      api :GET, '/job_queues', 'List job queues'
      param_group :pagination, V1::BaseController
      param :status, /^[0-9]+$/, desc: 'Job status ID'
      def index
        super
      end

      api :GET, '/job_queues/:id', 'Show a job queue'
      param :id, /^[0-9]+$/, desc: "Job queue ID", required: true
      def show
        super
      end

      api :GET, '/job_queues/count', 'Count of job queues'
      param :status, /^[0-9]+$/, desc: 'Job status ID'
      def count
        @count = JobQueue.where(query_params).count
        respond_with @count
      end

      private

      def job_queue_params
        params.require(:job_queue).permit()
      end

      def query_params
        params.permit(:status, :proc_id)
      end

    end
  end
end
