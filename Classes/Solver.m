classdef Solver < handle
    % Don't make copies of large output matrices
    % Note that n=1 <=> y0 <=> t=0 and n=N <=> y(N+1), x(N) and t = N*dt
    % So if V>Vth at N, this corresponds to x(N), y(N+1) and t=N*dt
    
    properties
        solverfunction
        Y
        spiketimes
        neuron
        input
%         y0
    end
    
    methods
        function s=Solver(neuron, input, solverfunction)
            s.neuron = neuron;
            s.input = input;
            s.solverfunction = solverfunction;
        end
        
        % NB: deze functie pas aanroepen nadat de input is ingesteld
        function initialize(s, y0)
            if s.input.length==0
                error('Define input before initializing the solver!')
            end
            s.Y=zeros(s.input.length+1, s.neuron.dof); 
            s.Y(1,:)=y0;
            s.spiketimes=[];
        end
        
        function solve(s)
            s.solverfunction(s);
        end
                
    end
    
    methods (Static)
        
        function eulerreset(s)
            % Make local copies of variables used in the for loop
            % in order to speed up the solving process
            
            y = s.Y(1,:);
            ipl = s.input.length;
            ipv = s.input.input;
            neur = s.neuron;
            dt = s.input.dt;
            if isprop(s.neuron, 'ind01')
                ind01 = s.neuron.ind01;
                check01=true;
            else
                check01=false;
            end
            
            reset=s.neuron.reset;
            if reset
                threshold = neur.threshold;
                resetv = neur.resetv;
                resetcondition=neur.resetcondition;
                resetfunction=neur.resetfunction;
            end
            
            
            for n = 1 : ipl
                ip = ipv(n);
                y = y + dt * neur.neuronfunction(y, ip);
                
                if reset && resetcondition(threshold, y)
                    s.spiketimes = [s.spiketimes n*dt]; 
                    y=resetfunction(resetv, y);
                end
                
                if check01
                    if max(y(ind01)<0)>0
                        y(ind01(find((y(ind01)<0)==1)))=0;
                    end
                    if max(y(ind01)>1)>0
                        y(ind01(find((y(ind01)>1)==1)))=1;
                    end
                end
                    
                s.Y(n+1,:) = y;
            end
        end
        
        
        function rk4(s)
            % Make local copies of variables used in the for loop
            % in order to speed up the solving process
            y = s.Y(1,:);
            ipl = s.input.length;
            ipv = s.input.input;
            neur = s.neuron;
            dt = s.input.dt;
            if isprop(s.neuron, 'ind01')
                ind01 = s.neuron.ind01;
                check01=true;
            else
                check01=false;
            end
            
            reset=s.neuron.reset;
            if reset
                threshold = neur.threshold;
                resetv = neur.resetv;
                resetcondition=neur.resetcondition;
                resetfunction=neur.resetfunction;
            end
            
            for n = 1 : ipl
                clear k1 k2 k3 k4
                ip = ipv(n);
                k1 = dt * neur.neuronfunction(y, ip);
                k2 = dt * neur.neuronfunction(y+0.5.*k1, ip);
                k3 = dt * neur.neuronfunction(y+0.5.*k2, ip);
                k4 = dt * neur.neuronfunction(y+k3, ip);
                y = y + 1/6.*(k1 + k4) + 1/3.*(k2 + k3);
                
                if reset && resetcondition(threshold, y)
                    s.spiketimes = [s.spiketimes n*dt]; % Note that n=1 <=> y0 <=> t=0
                    y=resetfunction(resetv, y);
                end
                                
                if check01
                    if max(y(ind01)<0)>0
                        y(ind01(find((y(ind01)<0)==1)))=0;
                    end
                    if max(y(ind01)>1)>0
                        y(ind01(find((y(ind01)>1)==1)))=1;
                    end
                end
                
                if isnan(y)==zeros(size(y))
                    % gaat prima
                else
                    keyboard
                    error('NaN!!')
                end
                
                s.Y(n+1,:) = y;
            end
        end
    end
end

