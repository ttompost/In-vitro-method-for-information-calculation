classdef Neuron % value class
    
    properties
        dof
        reset   % true or false, depending on whether you have a reset or not
        vars
    end
    
    methods
        function n = Neuron(vars)
            n.vars = vars;
        end
        
    end
    
    methods (Static)
        %% Reset conditions
        function reset = simpleresetc(Vth, y)
            reset = (y(1) > Vth);
        end
        function reset = bayesianresetc(Vth, y)
            reset = ((y(1)-y(2)) > Vth);
        end
        
        %% Reset functions
        function y = simpleresetf(Vr, y)
            for i=1:length(Vr)
                y(i) = Vr(i);
            end
        end
        function y = simpleresetfadap(Vr, y)
            y(1) = Vr(1);
            y(2:end) = y(2:end)+Vr(2:end);
        end
        
        function y = bayesianresetf(eta, y)
%             y(1) = y(2)+eta/2;
            y(2) = y(2) + eta;
        end
        function y = bayesianresetfv(eta, y)
%             y(1) = -eta/2;
            y(1) = y(1) - eta;
            y(2) = y(2) + eta;
        end
        %% Currents
        function i=Ih(V, m, gh, Eh)
            i=gh.*m.*(V-Eh);
        end
        %% Rate Functions
        % Welie 2004
        function ahh=ahh(V)
            % V=1D
            ahh=0.071./(1+exp((V+108)/8.3));
        end
        
        function bhh=bhh(V)
            % V=1D
            bhh=0.24./(1+exp((V+26.5)./(-23)));
        end
        %% Other
        function xinf=xinf(a,b)
            xinf=a./(a+b);
        end
        
        function taux=taux(a,b)
            taux=1./(a+b);
        end
        
        function xinf=xinf_direct(Vh, k, V)
            xinf=1./(1+exp((Vh-V)./k));
        end
        
        function taux=taux_direct(Cbase, Camp, Vmax, sigma, V)
            % izhikevich style
            taux=Cbase+Camp.*(exp((-(Vmax-V).^2)./sigma.^2));
        end
        
    end
end