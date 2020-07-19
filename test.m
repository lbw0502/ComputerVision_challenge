classdef test < matlab.unittest.TestCase
    %Test your challenge solution here using matlab unit tests
    %
    % Check if your main file 'challenge.m', 'disparity_map.m' and 
    % verify_dmap.m do not use any toolboxes.
    %
    % Check if all your required variables are set after executing 
    % the file 'challenge.m'
    
    properties
        %Tol = 0.1
    end
    
    methods (Test)
        function check_toolboxes(testCase)
            testCase.verifyFalse(testToolbox('disparity_map.m'));
            testCase.verifyFalse(testToolbox('verify_dmap'));
            testCase.verifyFalse(testToolbox('challenge.m'));
        end
        function check_variables(testCase)
            challenge;

            testCase.verifyNotEmpty(members);
            testCase.verifyNotEmpty(mail);
            testCase.verifyEqual(group_number, 36);
            testCase.verifyGreaterThan(elapsed_time, 0);
            
            testCase.verifyNotEmpty(D);
            testCase.verifyNotEmpty(R);
            testCase.verifyNotEmpty(T);
            testCase.verifyNotEmpty(p);
            
%             testCase.verifyGreaterThan(D, 0);
%             testCase.verifyGreaterThanOrEqual(R, 0);
%             testCase.verifyGreaterThan(T, 0);
%             testCase.verifyGreaterThan(p, 0);
        end
        function check_psnr(testCase)
            import matlab.unittest.constraints.AbsoluteTolerance;
            import matlab.unittest.constraints.IsEqualTo;

            challenge;
            p_value = verify_dmap(D, G);
            p_truth = psnr(D, G, 255);
            disp(p_truth);
            disp(p_value);
            testCase.verifyThat(p_value, IsEqualTo(p_truth, 'within', AbsoluteTolerance(0.1)))
        end
    end
    
end


function Toolboxes_used = testToolbox(filename)
        [fList, pList] = matlab.codetools.requiredFilesAndProducts(filename);
        if (size({pList.Name}', 1)>1)
            Toolboxes_used = true;
        else
            Toolboxes_used = false;
        end
end