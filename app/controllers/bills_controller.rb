class BillsController < ApplicationController
  before_action :set_bill, only: [:show, :edit, :update, :destroy]

  # GET /bills
  # GET /bills.json
  def index
    @bills = Bill.all
  end

  # GET /bills/1
  # GET /bills/1.json
  def show
  end

  # GET /bills/new
  def new
    @bill = Bill.new
  end

  # GET /bills/1/edit
  def edit
  end

  # POST /bills
  # POST /bills.json
  def create
    @bill = Bill.new(bill_params)

    respond_to do |format|
      if @bill.save
        format.html { redirect_to food_events_path, notice: 'Bill was successfully created.' }
        format.json { render :show, status: :created, location: @bill }
      else
        format.html { render :new }
        format.json { render json: @bill.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /bills/1
  # PATCH/PUT /bills/1.json
  def update
    respond_to do |format|
      if @bill.update(bill_params)
        format.html { redirect_to food_events_path, notice: 'Bill was successfully updated.' }
        format.json { render :show, status: :ok, location: @bill }
      else
        format.html { render :edit }
        format.json { render json: @bill.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /bills/1
  # DELETE /bills/1.json
  def destroy
    @bill.destroy
    respond_to do |format|
      format.html { redirect_to bills_url, notice: 'Bill was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def add_bill
    @bill = Bill.new()
    @event=FoodEvent.find(params[:id])
  end

  def edit_bill
    @event=FoodEvent.find(params[:id])
    @bill=@event.bill
  end


  def remaining_payment
       @amarpaytoakbar=0
       @amarpaytoanthony=0
       @akbarpaytoamar=0
       @akbarpaytoanthony=0
       @anthonypaytoamar=0
       @anthonypaytoakbar=0


       FoodEvent.all.each do |food_event|
        count_people=0
        count_people=count_people+1 if food_event.amar_present == true
        count_people=count_people+1 if food_event.akbar_present == true
        count_people=count_people+1 if food_event.anthony_present == true
        
        bill_amount = food_event.bill.total
        bill = food_event.bill
        single_contribution = bill_amount / count_people

        if   food_event.amar_present == true
             if bill.amar_paid < single_contribution
                    if count_people == 2
                        if food_event.akbar_present == true
                            @amarpaytoakbar = @amarpaytoakbar + (single_contribution - bill.amar_paid)
                        end
                        if food_event.anthony_present == true
                            @amarpaytoanthony = @amarpaytoanthony + (single_contribution - bill.amar_paid)
                        end
                    else
                         remaining_amount = single_contribution - bill.amar_paid
                           if bill.anthony_paid > single_contribution

                                   if ((bill.anthony_paid - single_contribution) >=  remaining_amount)

                                     @amarpaytoanthony = @amarpaytoanthony + remaining_amount     
                                   else
                                     @amarpaytoanthony = @amarpaytoanthony + (bill.anthony_paid - single_contribution)
                                     remaining_amount = remaining_amount - (bill.anthony_paid - single_contribution)
                                   end
                            
                                   if bill.akbar_paid > single_contribution

                                      @amarpaytoakbar = @amarpaytoakbar + remaining_amount  

                                   end
         
                          end  
                  end
            end
        end 
        if   food_event.akbar_present == true
               if bill.akbar_paid < single_contribution
                      if count_people == 2
                          if food_event.amar_present == true
                              @akbarpaytoamar = @akbarpaytoamar + (single_contribution - bill.akbar_paid)
                          end
                          if food_event.anthony_present == true
                              @akbarpaytoanthony = @akbarpaytoanthony + (single_contribution - bill.akbar_paid)
                          end
                      else
                        remaining_amount = single_contribution - bill.akbar_paid

                              if ((bill.amar_paid - single_contribution) >=  remaining_amount)
             
                                 @akbarpaytoamar = @akbarpaytoamar + remaining_amount 
                              else   
                                 @akbarpaytoamar = @akbarpaytoamar + (bill.amar_paid - single_contribution) 
                                 remaining_amount = remaining_amount - (bill.amar_paid - single_contribution)
             
                              end

                              if bill.anthony_paid > single_contribution
                                 @akbarpaytoanthony = @akbarpaytoanthony + remaining_amount  
                              end
                           
       
                      end  
               end
        end

         if   food_event.anthony_present == true
               if bill.anthony_paid < single_contribution
                    if count_people == 2
                          if food_event.amar_present == true
                              @anthonypaytoamar = @anthonypaytoamar= + (single_contribution - bill.anthony_paid)
                          end
                          if food_event.akbar_present == true
                              @anthonypaytoakbar = @anthonypaytoakbar + (single_contribution - bill.anthony_paid)
                          end
                    else
                        remaining_amount = single_contribution - bill.anthony_paid

                            if ((bill.amar_paid - single_contribution) >=  remaining_amount)
                              @anthonypaytoamar = @anthonypaytoamar +  remaining_amount
                            else
                               @anthonypaytoamar = @anthonypaytoamar +   (bill.amar_paid - single_contribution)
                               remaining_amount = remaining_amount - (bill.amar_paid - single_contribution)
                            end
                            
                            if bill.akbar_paid > single_contribution
                              @anthonypaytoakbar = @anthonypaytoakbar +  remaining_amount
                            end
                         
                    end  
               end
        end


       end



  end




  private
    # Use callbacks to share common setup or constraints between actions.
    def set_bill
      @bill = Bill.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def bill_params
      params.require(:bill).permit(:total, :amar_paid, :akbar_paid, :anthony_paid,:food_event_id)
    end
end
