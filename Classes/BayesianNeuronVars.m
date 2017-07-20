classdef BayesianNeuronVars % value class
    %choose either ron+roff, or P0+tau, and theta or V0
    
    properties
        ron=0.01;
        roff=0.1;
        theta=0.1;
        eta=0.1;
    end
    
    properties (Dependent, Hidden)
        V0
        P0
        tau
    end
    
    methods
        
        function b = BayesianNeuronVars()
        end
        
        
        function p = get.P0(b)
            p = b.ron/(b.ron+b.roff);
        end
        
        function t = get.tau(b)
            t = 1/(b.ron+b.roff);
        end
        
        function v = get.V0(b)
            v=-b.tau*b.theta;
        end
        
        function b = set.P0(b, P0)
            % ron and roff change, tau stays the same
            tau = b.tau;
            b.ron = P0/tau;
            b.roff = (1-P0)/tau;
            if (tau-b.tau)>eps
                error('running out of machine precision with setting P0')
            end
        end
        
        
        function b = set.tau(b, tau)
            % ron and roff change, P0 stays the same
            P0 = b.P0;
            b.ron = P0/tau;
            % let op! b.P0 is dus nu anders!
            b.roff = (1-P0)/tau;
            % nu is b.P0 weer gelijk aan P0
            if(b.P0-P0)>eps
                error('running out of machine precision with setting tau')
            end
        end
        
        function b = set.V0(b, v0)
            % theta changes, tau stays the same
            b.theta = -v0/b.tau;
        end
        
         
    end
    
end