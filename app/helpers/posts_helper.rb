module PostsHelper
  def prev_link_text
    "&larr; #{h(@post.prev.title)}"
  end

  def next_link_text
    "#{h(@post.next.title)} &rarr;"
  end

  def delete_link
    link_to 'Delete', post_path(@post), :method => :delete, :confirm => "Really delete #{@post.title}?"
  end

  def post_content(post)
    absolute_anchors(find_and_preserve(post.render).gsub(/<img src=("|')\//,
                                                         "<img src=\\1#{feed[:url]}"),
                     post_path(post))
  end

  def date_links
    if @prev_link || @next_link
      open 'div', :class => 'date_links' do
        open 'div', @prev_link, :class => 'prev' if @prev_link
        open 'div', @next_link, :class => 'next' if @next_link
      end
    end
  end

  def spam_comment_link
    link_to('Spam', post_comment_path(@post, @comment) + '?spam=1',
            :method => :delete, :confirm => 'Mark comment as spam and delete it?')
  end

  def delete_comment_link
    link_to 'Delete', post_comment_path(@post, @comment), :method => :delete, :confirm => 'Delete comment?'
  end

  def edit_comment_link
    link_to_remote('Edit', {
                     :url => edit_post_comment_path(@post || @comment.post, @comment) + '.html',
                     :update => "comment_#{@comment.id}_content", :method => :get
                   }, :title => 'Edit comment')
  end

  # Feed helpers

  @@feed_info = {
    :url => "http://#{Nex3::Config['blog']['site']}/",
    :desc => "#{Nex3::Config['author']['name']}'s blog, all about things that interest him.",
    :name => Nex3::Config['author']['name'],
    :email => Nex3::Config['author']['email'],
    :ttl => 1440,
  }

  def self.feed
    @@feed_info
  end

  def feed
    @@feed_info
  end
end
