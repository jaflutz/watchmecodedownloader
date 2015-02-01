require 'mechanize'
require 'logger'

agent = Mechanize.new
logger = Logger.new(STDOUT)

def append_entry(filename)
  File.open(ENV['WATCH_HOME_INDEX'], "a+") do |file|
    file << filename + "\n"
  end
end

def already_downloaded(filename)
   File.read(ENV['WATCH_HOME_INDEX']).split(/\n/).include?(filename)
end

agent.pluggable_parser.default = Mechanize::Download

agent.get('https://sub.watchmecode.net/login/') do |login_page|
  #Submit login form
  index_page = login_page.form_with(id: 'rcp_login_form') do |login_form|
    login_form.rcp_user_login = ENV['WATCH_USERNAME']
    login_form.rcp_user_pass = ENV['WATCH_PASSWORD']
  end.submit

  for i in 1..12
    agent.get("https://sub.watchmecode.net/categories/episodes/page/" + i.to_s + "/") do |episodes_page|
      puts episodes_page.links_with(text: /Episode \d\d/)
      episodes_page.links_with(text: /Episode \d\d/).each do |episode_link|
        episode_page = episode_link.click
        puts "Clicked in " + episode_link.text
        #puts episode_page.links
        download_link = episode_page.link_with(text: /Download/)
        unless download_link == nil then
          puts download_link.href
        end

        unless already_downloaded(episode_link.text) then
         agent.get(download_link.href).save(File.join(ENV['WATCH_HOME'], episode_link.text))
         append_entry(episode_link.text)
        end
      end
    end
  end

#  index_page.links_with(text: /Attachments/).each do |attachment_link|
#    files_page = attachment_link.click
#    puts "Clicked "
#    links_list = files_page.search('.blog-entry li a')
#
#    tapas_home = File.join(ENV['TAPAS_HOME'], links_list[0].text)
#
#    unless already_downloaded(links_list[0].text) or links_list[0].text.start_with?("http") then
#      Dir.mkdir(tapas_home, 0700)
#      links_list.each do |link|
#        puts link
#        agent.get(link['href']).save(File.join(ENV['TAPAS_HOME'], links_list[0].text, link.text))
#      end
#      append_entry(links_list[0].text)
#    end
#  end

end




