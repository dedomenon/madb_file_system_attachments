module FileAttachmentModule
module FileSystemStorage

  def self.included(base)
    base.class_eval do  
	alias_method_chain :save, :file_system
  	@@base_dir = AppConfig.file_system_attachments_path
    end
    base.extend(ClassMethods)

  end
  def initialize(*args)
    super(*args)
  end
  def size
    @attachment.size
  end
  

  def file_path
    "#{local_instance_path}/#{self.id.to_s}"
  end
  def save_with_file_system
    save_without_file_system
    @attachment.rewind
    
    if !FileTest.directory?( local_instance_path )
      FileUtils.mkdir_p( local_instance_path )
    end
     
     File.open(file_path, "wb") do |f| 
       f.write(@attachment.read) 
     end
     
    
     o = value
     #o[:uploaded] = true
     ## Save the value id also
     o[:detail_value_id] = id
     #value = o
     write_attribute(:value, o)
     #
#     update_attribute(:value, o.to_yaml)
     save_without_file_system
     
  end
  
  
  def destroy
    super
    File.delete(local_instance_path+"/"+self.id.to_s)
    detail.database.account.decrement(:attachment_count).save
  end
  
  def instance_prefix
      %Q{#{account_id}/#{database_id}/#{entity_id}/#{instance_id}}
  end


  def local_instance_path
    %Q{#{@@base_dir}/#{instance_prefix}}
  end

  def send_file_spec
  	{ :method => :send_file, :data => { :path => file_path }}
  end
  
# Class methodes

  module ClassMethods
  end
end
end
