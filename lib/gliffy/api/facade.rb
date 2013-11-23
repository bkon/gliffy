module Gliffy
  class API
    class Facade
      def self.http(api)
        Facade.new("http", api)
      end

      def self.https(api)
        Facade.new("https", api)
      end

      def raw(partial_url, params = {})
        api.raw(api_root + partial_url, params)
      end

      def get(partial_url, params)
        response = api.get(api_root + partial_url, params)

        if response.error?
          handle_error response
        end

        response
      end

      def post(partial_url, params)
        response = api.post(api_root + partial_url, params)

        if response.error?
          handle_error response
        end

        response
      end

      def web(partial_url, params)
        api.web(web_root + partial_url, params)
      end

      # Path  is alphanumeric  +  spaces and  '/'.   Spaces should  be
      # escaped; slashes should NOT be escaped.
      def escape_path(path)
        path.gsub(' ', '+')
      end

      def get_folders(account_id)
        get("/accounts/#{account_id}/folders.xml",
            :action => "get")
      end

      def get_users(account_id)
        get("/accounts/#{account_id}/users.xml",
            :action => "get")
      end

      def update_document_metadata(document_id, name, shared)
        params = {
          :action => "update",
        }

        if not name.nil?
          params[:documentName] = name
        end

        if not shared.nil?
          params[:public] = shared ? "true" : "false"
        end

        post("/accounts/#{account_id}/documents/#{document_id}/meta-data.xml",
             params)
      end

      def delete_document(document_id)
        post("/accounts/#{account_id}/documents/#{document_id}.xml",
             :action => "delete")
      end

      def move_document(document_id, folder_path)
        post("/accounts/#{account_id}/folders/#{escape_path folder_path}/documents/#{document_id}.xml",
             :action => "move")
      end

      def get_documents_in_folder(path)
        get("/accounts/#{account_id}/folders/#{escape_path path}/documents.xml",
            :action => "get")
      end

      def delete_folder(path)
        post("/accounts/#{account_id}/folders/#{escape_path path}.xml",
             :action => "delete")
      end

      def create_document(name, type, original_id, path)
        params = {
          :action => "create",
          :documentName => name,
          :documentType => type
        }

        if not original_id.nil?
          params[:templateDiagramId] = original_id
        end

        if not path.nil?
          params[:folderPath] = path
        end

        post("/accounts/#{account_id}/documents.xml",
             params)
      end

      def create_folder(path)
        post("/accounts/#{account_id}/folders/#{path}.xml",
             :action => "create")
      end

      private

      def handle_error(response)
        code = response.integer("//g:response/g:error/@http-status")
        text = response.string("//g:response/g:error/text()")

        raise Gliffy::API::Error.new(code, text)
      end

      def api
        @api
      end

      def account_id
        api.account_id
      end

      def initialize(protocol, api)
        @protocol = protocol
        @api = api
      end

      def api_root
        @protocol + ":" + Gliffy.api_root
      end

      def web_root
        @protocol + ":" + Gliffy.web_root
      end
    end
  end
end
