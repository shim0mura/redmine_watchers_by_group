module Redmine_watchers_by_group
  class Hooks < Redmine::Hook::ViewListener
    def controller_issues_edit_before_save(context)
      issue = context[:issue]
      current_watcher_id = issue.watchers.map{|watcher| watcher.user_id}
      new_watcher_id = context[:params][:issue][:watcher_user_ids].map{|watcher| watcher.to_i}

      remove_watcher = User.find(current_watcher_id - new_watcher_id)
      add_watcher = User.find(new_watcher_id - current_watcher_id)

      remove_watcher.each do |watcher|
        issue.remove_watcher(watcher)
      end

      add_watcher.each do |watcher|
        issue.add_watcher(watcher)
      end
    end

    def view_issues_form_details_bottom(context={ })
      context[:watchers] = (context[:issue].project.users.sort + context[:issue].watcher_users).uniq

      context[:controller].send(:render_to_string, {
          :partial => 'watchers/multiselect_group',
          :locals => context
        })
    end
  end
end
