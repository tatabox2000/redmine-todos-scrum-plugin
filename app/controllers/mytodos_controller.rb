#require 'ruby-debug'

class MytodosController < ApplicationController

  before_filter :authorize

  def index
    #get all the root level todos belonging to current user
    @todos = User.current.todos.select{|t| t.parent_id == nil }
    
    #group the results by project, into a hash keyed on project.
  	#this line is so beautiful it nearly made me cry!
  	@grouped_project_todos = Set.new(@todos).classify{|t| t.project } 
  	
  	#debugger
  	
  	#personal todos are just normal todos with no project id. 
  	#Grab them and remove them from the project list.
  	@personal_todos = @grouped_project_todos.delete(nil).to_a
  	
    @new_todo = Todo.new(:author_id => User.current.id)
  end
  
  def new
    @todo = Todo.new
    @todo.parent_id = Todo.find(params[:parent_id]).id
    @todo.assigned_to = User.current
    render :partial => 'new_todo', :locals => { :todo => @todo, :update_target => params['update_target']}
  end
  
  def create
    @todo = Todo.new(params[:todo])
    @todo.author = User.current
    
    #debugger
    if @todo.save
    
      if (request.xhr?)
        render :partial => 'todos/todo', :locals => { :todo => @todo, :editable => true }
      else
        flash[:notice] =  @todo.errors.collect{|k,m| m}.join
        redirect_to :action => "index"
      end
    else
    	render :text => @todo.errors.collect{|k,m| m}.join
    end
  end
  
  def destroy
    @todo = Todo.find_by_user(params[:id], User.current.id)
    
    if @todo.destroy
      render :text => ""
    else
      render :text => @todo.errors.collect{|k,m| m}.join
    end
  end
  
  def toggle_complete
    @todo = Todo.find_by_user(params[:id], User.current.id)
    @todo.set_done !@todo.done
    redirect_to :action => "index"
  end
  
  def sort
		
    @todos = User.current.todos
    
    params.keys.select{|k| k.include? "todo-children-ul_" }.each do |key|
		  Todo.sort_todos(@todos,params[key])
		end

    render :nothing => true
  end
  
  
end
