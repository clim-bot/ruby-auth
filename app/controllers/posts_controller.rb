class PostsController < ApplicationController
  # This means users can view posts without logging in.
  skip_before_action :verify_authenticity_token, only: [ :index, :show ]
  # Allow unauthenticated access for index and show actions
  allow_unauthenticated_access only: [ :index, :show ]
  # This controller handles the CRUD operations for posts.
  before_action :require_authentication, except: [ :index, :show ]
  # Ensure the user is logged in for all actions except index and show
  before_action :set_post, only: [ :show, :edit, :update, :destroy ]
  # Ensure the post is set for actions that require it
  before_action :authorize_user!, only: [ :edit, :update, :destroy ]

  # GET /posts or /posts.json
  def index
    @posts = Post.all
  end

  # GET /posts/1 or /posts/1.json
  def show
  end

  # GET /posts/new
  def new
    @post = Post.new
  end

  # GET /posts/1/edit
  def edit
  end

  # POST /posts or /posts.json
  def create
    # Build a new post associated with the current user
    @post = current_user.posts.build(post_params)

    respond_to do |format|
      if @post.save
        format.html { redirect_to @post, notice: "Post was successfully created." }
        format.json { render :show, status: :created, location: @post }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @post.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /posts/1 or /posts/1.json
  def update
    respond_to do |format|
      if @post.update(post_params)
        format.html { redirect_to @post, notice: "Post was successfully updated." }
        format.json { render :show, status: :ok, location: @post }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @post.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /posts/1 or /posts/1.json
  def destroy
    @post.destroy!

    respond_to do |format|
      format.html { redirect_to posts_path, status: :see_other, notice: "Post was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_post
      @post = Post.find(params[:id])
    end

    # Authenticate the user before allowing access to certain actions
    def authorize_user!
      redirect_to posts_path, alert: "Not authorized." unless @post.user == current_user
    end

    # Only allow a list of trusted parameters through.
    def post_params
      params.require(:post).permit(:title, :body, :published)
    end
end
