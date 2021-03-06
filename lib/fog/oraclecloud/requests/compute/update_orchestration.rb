module Fog
  module Compute
    class OracleCloud
      class Real
      	def update_orchestration (name, oplans, options={})

          # Clean up names in case they haven't provided the fully resolved names
          if !name.start_with?("/Compute-") then
            # They haven't provided a well formed name, add their name in
            name = "/Compute-#{@identity_domain}/#{@username}/#{name}"
          end   
          oplans.map do |oplan|
            oplan['objects'].map do |object|
              if oplan['obj_type'] == 'launchplan' then
                object['instances'].map do |instance|
                  if !instance['name'].start_with?("/Compute-") then
                    instance['name'] = "/Compute-#{@identity_domain}/#{@username}/#{instance['name']}"
                  end
                end
              else
                if !object['name'].start_with?("/Compute-") then
                  object['name'] = "/Compute-#{@identity_domain}/#{@username}/#{object['name']}"
                end
              end
            end
          end
          body_data     = {
            'name' 		      => name,
            'oplans'        => oplans,
            'relationships' => options[:relationships],
            'description'   => options[:description],
            'account'       => options[:account],
            'schedule'      => options[:schedule]
          }
          body_data = body_data.reject {|key, value| value.nil?}
          request(
            :method   => 'PUT',
            :expects  => 200,
            :path     => "/orchestration#{name}",
            :body     => Fog::JSON.encode(body_data),
            :headers  => {
              'Content-Type' => 'application/oracle-compute-v3+json'
            }
          )
      	end
      end

      class Mock
        def update_orchestration (name, oplans, options={})
          response = Excon::Response.new
          clean_name = name.sub "/Compute-#{@identity_domain}/#{@username}/", ''
          if orchestration = self.data[:orchestrations][clean_name] 
            oplans.map do |oplan|
              oplan['objects'].map do |object|
                if oplan['obj_type'] == 'launchplan' then
                  object['instances'].map do |instance|
                    if !instance['name'].start_with?("/Compute-") then
                      instance['name'] = "/Compute-#{@identity_domain}/#{@username}/#{instance['name']}"
                    end
                  end
                else
                  if !object['name'].start_with?("/Compute-") then
                    object['name'] = "/Compute-#{@identity_domain}/#{@username}/#{object['name']}"
                  end
                end
              end
            end
            self.data[:orchestrations][clean_name].merge!(options)
            self.data[:orchestrations][clean_name]['oplans'] = oplans
            response.status = 200
            response.body = self.data[:orchestrations][clean_name]
            response
          else;
            raise Fog::Compute::OracleCloud::NotFound.new("Orchestration #{name} does not exist");
          end
        end
      end
    end
  end
end
