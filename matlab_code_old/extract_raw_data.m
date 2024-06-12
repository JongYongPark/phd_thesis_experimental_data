function [cap,cTemp,cTime,cV,cI,cVcharge,cIcharge,dTemp,dTime,dV,dI,dIload] = extract_raw_data(B,index)
% function [cap,cTemp,cTime,cV,cI,cVcharge,cIcharge,dTemp,dTime,dV,dI,dIload,icCsense,icCbattery,icCratio,icBatImp,icRecImp,idCsense,idCbattery,idCratio,idBatImp,idRecImp] = extract_raw_data(B,index)

% v4 - delete regenratoin cycle

%% all
%cap,cTempMax,cTempMaxDt,cTempMaxDtAdj,ohm,re_c,re_d,dTempMax,dTempMaxDt,dTempMaxDtAdj
% cap 에서 하나의 index 가 빠진다. 하지만 일단 무시해도 된다.

    % cycle pattern
    % charge ( impenedace ) discarge ( impedance )
    bcycle = B.cycle;
    cycle_index = 1;
    cap_prev = 100;
    last_charge_reverse_index = 3;
    
    %  temp
    prevTemp = 0;
    cTempMaxIndex_prev = 1;

    % restTimeOption 
    %restTimeOption = 0; % charge high temp ~ start discharge
    restTimeOption = 1; % last discharge staring time ~ current dischage starting time
    
    %  ohm
    deltaVoltages = [];
    %ohm = [];
    Ifirst3 = 2; % 2A CC load
    Vfirst3 = 4.2;
    indexV = []; 
    re_c =[];
    re_d =[];
    ohm_start_index = 1;
    ohm_measure_index = 5;
    imp_d_index = 1;
    max_cycle_org = length(bcycle);
    
    total_discharge_cycle = 0;
    for j = max_cycle_org:-1:2
        if isequal(bcycle(j).type,'discharge' )
            total_discharge_cycle = total_discharge_cycle +1;
        end
        if isequal(bcycle(j).type, bcycle(j-1).type) 
            if isequal(bcycle(j).type,'discharge' )
                sprintf("break here")
            end
            bcycle(j)=[];
        end
    end 
    
    
    max_cycle = length(bcycle);
    for i = 1:max_cycle
        % start from charge [impedance] discharge [impedance]
        if isequal(bcycle(i).type, 'charge') && ( i <=  max_cycle - last_charge_reverse_index  ) ...
                && ((isequal(bcycle(i+1).type, 'discharge') || isequal(bcycle(i+2).type, 'discharge')) )

           %% Cycle index  
           if cycle_index ~= index
               cycle_index = cycle_index +1;
               continue;
           end
               
            if isequal(bcycle(i+1).type, 'discharge')
                discharge_index = i+1;

                imp_c_index = -1;         
                if isequal(bcycle(i+2).type, 'impedance')
                    imp_d_index = i+2;
                else 
                    imp_d_index = -1;
                end 
            elseif isequal(bcycle(i+2).type, 'discharge')
                discharge_index = i+2;

                if isequal(bcycle(i+1).type, 'impedance')
                    imp_c_index = i+1;
                else   
                    imp_c_index = -1;
                end

                if (i+last_charge_reverse_index <= max_cycle)  &&  (isequal(bcycle(i+3).type, 'impedance'))
                    imp_d_index = i+3;
                else   
                    imp_d_index = -1;
                end
            else
                sprintf("error ")
            end    
            

            cTemp_ = bcycle(i).data.Temperature_measured;
            cTime_ = bcycle(i).data.Time;
            cV_ = bcycle(i).data.Voltage_measured;
            cI_ = bcycle(i).data.Current_measured;
            cVcharge_ = bcycle(i).data.Voltage_measured;
            cIcharge_ = bcycle(i).data.Current_measured;

            
            cTemp = cTemp_ ;
            cTime= cTime_ ;
            cV= cV_ ;
            cI= cI_ ;
            cVcharge= cVcharge_ ;
            cIcharge= cIcharge_ ;
            
            dTemp_ = bcycle(discharge_index).data.Temperature_measured;
            dTime_ = bcycle(discharge_index).data.Time;
            dV_ = bcycle(discharge_index).data.Voltage_measured;
            dI_ = bcycle(discharge_index).data.Current_measured;
            dVload_ = bcycle(discharge_index).data.Voltage_load;
            dIload_ = bcycle(discharge_index).data.Current_load;
            
            dTemp= dTemp_ ;
            dTime= dTime_ ;
            dV= dV_ ;
            dI= dI_ ;
            dVload= dVload_ ;
            dIload= dIload_ ;
                
            %% Capacity
            
            % ignore rest regeneratoin.
            cap_value = bcycle(discharge_index).data.Capacity;
            cap = cap_value;
            
 
            %% Impedance - only use re. do not use rct and others
            if false
                if imp_c_index ~= -1 
                    icCsense_ = bcycle(imp_c_index).data.Sense_current;
                    icCbattery_ = bcycle(imp_c_index).data.Battery_current;
                    icCratio_ = bcycle(imp_c_index).data.Current_ratio;
                    icBatImp_ = bcycle(imp_c_index).data.Battery_impedance;
                    icRecImp_ = bcycle(imp_c_index).data.Rectified_impedance;

                    icCsense= icCsense_ ;
                    icCbattery= icCbattery_ ;
                    icCratio= icCratio_ ;
                    icBatImp= icBatImp_ ;
                    icRecImp= icRecImp_ ;
                end 

                if imp_d_index ~= -1 
                    idCsense_ = bcycle(imp_d_index).data.Sense_current;
                    idCbattery_ = bcycle(imp_d_index).data.Battery_current;
                    idCratio_ = bcycle(imp_d_index).data.Current_ratio;
                    idBatImp_ = bcycle(imp_d_index).data.Battery_impedance;
                    idRecImp_ = bcycle(imp_d_index).data.Rectified_impedance;    

                    idCsense= idCsense_ ;
                    idCbattery= idCbattery_ ;
                    idCratio= idCratio_ ;
                    idBatImp= idBatImp_ ;
                    idRecImp= idRecImp_ ;                 
                end
            end

            
         
            
            cycle_index = cycle_index +1;

        else
            %sprintf("out %d",i)
        end

        %i = i+1;
        break;
    end % end for

% result = [cap,cTemp,cTime,cV,cI,cVcharge,cIcharge ,dTemp,dTime,dV,dI,dIload ,icCsense,icCbattery,icCratio,icBatImp,icRecImp ,idCsense,idCbattery,idCratio,idBatImp,idRecImp ];


end % end function

