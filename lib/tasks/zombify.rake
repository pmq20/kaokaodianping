# coding: utf-8
@zombies = []

namespace :experts do
  task :zombify => :environment do
    zombies = File.expand_path('./auxiliary/zombies.txt',Rails.root)
    p zombies
    begin
      if File.exists?(zombies)
        File.open(zombies) do |f|
          while(line=f.gets)
            email=line.strip
            next if ''==email
            u = User.where(email:email).first
            unless u
              u = User.new
              u.email = email
              u.name = email.split('@')[0]
              u.name = u.name.force_encoding("UTF-8") if u.name and u.name!=''
              u.name = u.name.split('@')[0]
              slug = email.split('@')[0]
              slug = slug[0..7] if slug.size>8
              slug += Time.now.to_i.to_s if User.find_by_slug(slug)
              u.slug=slug.split('.').join('-')
              u.save!(:validate => false)
              puts "zombie created\n"
            end
            @zombies << u
            User.where(:is_expert=>true).each do |expert|
              @zombies.each do |zombie|
                zombie.follow(expert)
              end
            end
            puts "#{line} processed\n"
          end
        end
        puts "#{zombies} loaded.\n"
      else
        raise "Please put zombies line by line at #{zombies}"
      end
    rescue => e
      puts "Something went wrong:\n"
      puts "#{e}"
    end
  end
end

