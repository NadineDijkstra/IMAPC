function D = read_data(cfg)

% Unpack data structure
v2struct(cfg)

% Read in text file
fid = fopen(dataFile,'r');
text = textscan(fid,'%s','Delimiter',','); 
text = text{1};

%% Reformat into something more usable
TextEnd = false;
refText = cell(length(text),1);
count1  = 1;
count2  = 1;
textToRef = [];
while ~TextEnd    
    
    textToRef(count1) = count2;
    
    % parse into text and numbers
    num = []; str = [];
    for i = 1:length(text{count1})
        if isletter(text{count1}(i))
            str = [str; i];
        elseif ~isnan(str2double(text{count1}(i)))
            num = [num; i];
        end
    end
    
    if ~isempty(str)
        if strcmp(text{count1}(str(1)),'Q') 
            str(2) = num(1);
            num(1) = [];
        end
    end
    
    % convert to strings and numbers 
    if ~isempty(num); num = str2double(text{count1}(num(1):num(end))); end
    if ~isempty(str); str = text{count1}(str(1):str(end)); end
    
    % assign to cells 
    if ~isempty(num) && ~isempty(str)
        firstNum = num(1) < str(1);       
        
        if firstNum
            refText{count2} = num;
            count2 = count2 + 1;
            refText{count2} = str;
        else
            refText{count2} = str;
            count2 = count2 + 1;
            refText{count2} = num; 
        end
    elseif ~isempty(num)
        refText{count2} = num;
    elseif ~isempty(str)        
        refText{count2} = str;
    elseif isempty(num) && isempty(str)
        refText{count2} = [];
    end      
    
    count1 = count1+1;    
    count2 = count2+1;
    
    % check end text
    if count1 > length(text)
        TextEnd = true;
    end  
end


%% Get the header
nCol = 17;
header = cell(1,nCol);
for c = 1:nCol
    header{c} = refText{c};
end

%% Make it into an actual data spreadsheet
trial_types = {'html-keyboard-response','animation','survey-text','call-function'};
trl_idx = find(contains(text,trial_types));
trl_idx(trl_idx < nCol) = []; %  cut off header
nTrials = length(trl_idx);
data = cell(nTrials,nCol);
data(1,:) = header;
str_idx = find(cellfun(@ischar,refText)==1);
for t = 1:nTrials
    
    ref_idx = textToRef(trl_idx(t));
    
    % check
    if ~ismember(trial_types,refText{ref_idx}) & ~strcmp(refText{ref_idx},'animation_sequence')
        error('Something is going wrong here!')
    end
    
    % do something different per trial type
    if strcmp(refText{ref_idx},trial_types{1}) % html keyboard responses
        
        if ref_idx+15 < length(refText)
            textSnip = refText(ref_idx-5:ref_idx+15); 
        else
            textSnip = refText(ref_idx-5:end); 
        end
        data{t+1,3} = trial_types{1}; % trial type        
              
        % Get them numbers and strings
        nums = find(cellfun(@isnumeric,textSnip) == 1);
        strs = find(cellfun(@ischar,textSnip) == 1);
        strs(strs < nums(1)) = [];
        for i = 1:length(strs)
            if length(textSnip(strs(i))) > 50 && length(textSnip{strs(i)+1}) > 50
                textSnip{strs(i)} = cat(2,textSnip{strs(i)},textSnip{strs(i)+1});
                strs(i+1) = [];
            end
        end    
        nums(cellfun(@isempty,textSnip(nums)) == 1) = [];
        
        % Determine sub-trial type 
        if any(contains(textSnip(strs),'fixation'))
            type_idx = contains(textSnip(strs),trial_types(1));
            data{t+1,9} = 'fixation';            
            data{t+1,4} = textSnip{strs(type_idx)+1};
            data{t+1,5} = textSnip{strs(type_idx)+2};
            
        elseif any(contains(textSnip(strs),'det_practice')) % detection practice
            type2_idx = find(contains(textSnip(strs),'det_practice'));
            tmp = nums(nums<strs(type2_idx));
            data{t+1,9} = 'det_practice';
            data{t+1,1} = textSnip{nums(1)}; % RT
            data{t+1,4} = textSnip{nums(2)}; % trl index
            data{t+1,5} = textSnip{nums(3)}; % time elapsed
            data{t+1,8} = textSnip{tmp(end)};
            data{t+1,12} = textSnip{strs(type2_idx+1)};
            data{t+1,13} = textSnip{strs(type2_idx+2)};
       
        elseif any(contains(textSnip(strs),'ima_practice'))
            type1_idx = strs(contains(textSnip(strs),trial_types{1}));
            type2_idx = strs(contains(textSnip(strs),'ima_practice'));
            data{t+1,9} = 'ima_practice';
            tmp1 = nums(nums < type1_idx(1));
            tmp2 = nums(nums > type1_idx(1));
            tmp3 = nums(nums < type2_idx);
            data{t+1,1} = textSnip{tmp1(end)};
            data{t+1,4} = textSnip{tmp2(1)};
            data{t+1,5} = textSnip{tmp2(2)};
            data{t+1,11} = textSnip{tmp3(end)};
            
            % left or right tilt?
            left = str_idx(contains(refText(str_idx),'imagine  a left'));
            left = left(left < ref_idx); 
            right = str_idx(contains(refText(str_idx),'imagine  a right'));
            right = right(right < ref_idx);
            if isempty(right) 
                data{t+1,7} = 'left';
            elseif isempty(left) 
                data{t+1,7} = 'right';
            elseif left(end) > right(end) 
                data{t+1,7} = 'left';
            elseif right(end) > left(end)
                data{t+1,7} = 'right';
            end
            
        elseif any(contains(textSnip(strs),'ima_check'))
            type2_idx = find(contains(textSnip(strs),'ima_check'));
            tmp = nums(nums < strs(type2_idx));
            data{t+1,9} = 'ima_check';
            data{t+1,1} = textSnip{nums(1)};
            data{t+1,4} = textSnip{nums(2)};
            data{t+1,5} = textSnip{nums(3)};
            data{t+1,8} = textSnip{tmp(end)};
            data{t+1,12} = textSnip{strs(type2_idx+1)}; 
            data{t+1,13} = textSnip{strs(type2_idx+2)}; 
            
        elseif any(contains(textSnip(strs),'main_test')) % main trials
            type2_idx = find(contains(textSnip(strs),'main_test'));
            tmp = nums(nums < strs(type2_idx));
            data{t+1,9} = 'main_test';
            data{t+1,1} = textSnip{nums(1)};
            data{t+1,4} = textSnip{nums(2)};
            data{t+1,5} = textSnip{nums(3)};
            data{t+1,8} = textSnip{tmp(end)};
            data{t+1,12} = textSnip{strs(type2_idx+1)}; % correct response
            data{t+1,13} = textSnip{strs(type2_idx+2)}; % correct?  
            data{t+1,14} = textSnip{nums(end-2)}; % visibility
            data{t+1,15} = textSnip{nums(end-1)}; % stim id
            data{t+1,16} = textSnip{nums(end)}; % condition id
        else
            type1_idx = strs(strcmp(textSnip(strs),trial_types{1}));
            tmp = strs(strs > type1_idx);
            tmp1 = nums(nums > tmp(1));
            data{t+1,1} = textSnip{nums(1)}; % first num is RT
            data{t+1,7} = textSnip{tmp(1)}; % then comes stimulus which is txt
            data{t+1,4} = textSnip{nums(2)}; % trl idx
            
            data{t+1,5} = textSnip{nums(3)}; % time elapsed
            data{t+1,8} = textSnip{tmp1(1)}; % button press
            data{t+1,9} = 'instruction'; 
        end
        
    elseif strcmp(refText{ref_idx},trial_types{4}) % call-function
            
        if ref_idx+15 < length(refText)
            textSnip = refText(ref_idx-5:ref_idx+15); 
        else
            textSnip = refText(ref_idx-5:end); 
        end
        data{t+1,4} = trial_types{4}; % trial type        
              
        % Get them numbers and strings
        nums = find(cellfun(@isnumeric,textSnip) == 1);
        strs = find(cellfun(@ischar,textSnip) == 1);
        strs(strs < nums(1)) = [];
        for i = 1:length(strs)
            if length(textSnip(strs(i))) > 50 && length(textSnip{strs(i)+1}) > 50
                textSnip{strs(i)} = cat(2,textSnip{strs(i)},textSnip{strs(i)+1});
                strs(i+1) = [];
            end
        end    
        nums(cellfun(@isempty,textSnip(nums)) == 1) = [];
        
        % determine sub-trial type
        if any(contains(textSnip(strs),'stair_update')) % staircase update
            type2_idx = contains(textSnip(strs),'stair_update');
            data{t+1,9} = 'stair_update';
            data{t+1,1} = textSnip{nums(1)}; % RT
            data{t+1,5} = textSnip{nums([textSnip{nums}]>33000)};
            data{t+1,4} = textSnip{nums([textSnip{nums}]>33000)-1};
            id = find(nums > strs(type2_idx));
            data{t+1,17} = textSnip{nums(id(1))};
            data{t+1,16} = textSnip{nums(id(2))};
        end
        
    elseif strcmp(refText{ref_idx},trial_types{2}) % animation
        textSnip = refText(ref_idx:ref_idx+num_steps*4+10);
        textSnip(cellfun(@isempty,textSnip) == 1) = [];
        nums = find(cellfun(@isnumeric,textSnip) == 1);
        data{t+1,3} = trial_types{2};
        data{t+1,4} = textSnip{nums(1)};
        data{t+1,5} = textSnip{nums(2)};        
        data{t+1,7} = cell(num_steps,2); i = 1; j = 1;
        while j < length(textSnip)+1
            if ~ischar(textSnip{j})
                j = j + 1;
            elseif ~(contains(textSnip{j},'stim_') || contains(textSnip{j},'noise_'))
                j = j+1;
            elseif (contains(textSnip{j},'stim_') || contains(textSnip{j},'noise_'))
                if (contains(textSnip{j},'stim_'))
                    id = strfind(textSnip{j},'stim_');  
                else
                    id = strfind(textSnip{j},'noise_');
                end
                data{t+1,7}{i,1} = textSnip{j}(id:end);
                j = j+1;
                stp = j+2;
                if stp > length(textSnip); stp = length(textSnip); end
                for k = j:stp
                    if isnumeric(textSnip{k}) && ~isnan(textSnip{k})
                        data{t+1,12}{i,2} = textSnip{k};
                    end
                end                
                i = i + 1;
                j = k + 1;
            end
        end
        
   
     elseif strcmp(refText{ref_idx},trial_types{3}) % survey text
        textSnip = refText(ref_idx-5:ref_idx+20);
        
        % Get them numbers and strings
        nums = find(cellfun(@isnumeric,textSnip) == 1);
        strs = find(cellfun(@ischar,textSnip) == 1);
        strs(strs < nums(1)) = [];
        for i = 1:length(strs)
            if length(textSnip(strs(i))) > 50 && length(textSnip{strs(i)+1}) > 50
                textSnip{strs(i)} = cat(2,textSnip{strs(i)},textSnip{strs(i)+1});
                strs(i+1) = [];
            end
        end    
        nums(cellfun(@isempty,textSnip(nums)) == 1) = [];
        type_id = strs(contains(textSnip(strs),trial_types{3}));
        
        data{t+1,4} = textSnip{type_id};
        tmp1 = nums(nums > type_id);
        tmp2 = nums(nums < type_id);
        data{t+1,5} = textSnip{tmp1(1)};
        data{t+1,1} = textSnip{tmp2(end)};
        data{t+1,6} = textSnip{tmp1(2)};
        
        if t < 10
            Qs = strs(contains(textSnip(strs),'Q'));
            data{t+1,7} = textSnip{Qs}(12:end);         
        else
        Qs = strs(contains(textSnip(strs),'Q'));
        data{t+1,14} = cell(length(Qs),2);
        for q = 1:length(Qs)
            data{t+1,14}{q,1} = textSnip{Qs(q)}(1:2);  
            if q == 1 % age
                tmp = nums(nums < Qs(1));
                data{t+1,14}{q,2} = textSnip{tmp(end)};
            else
            data{t+1,14}{q,2} = textSnip{Qs(q)}(12:end);  
            end
        end  
        end
        
    elseif strcmp(refText{ref_idx},'animation_sequence')
        % something weird
    end 

end

clear refText Text

%% Now we turn this into actual things that we can do analyses on
D = [];

% - prolific ID - %
idx = find(strcmp(data(:,4),'survey-text'));
D.prolificID = data{idx(1),7};

% - practice - %
test_id = find(strcmp(data(:,9),'det_practice'));
pracTrials = length(test_id);
D.det_practice = zeros(pracTrials,2);
for p = 1:pracTrials
    if strcmp(data{test_id(p),13},'true')
        D.det_practice(p,1) = 1;
    end
    D.det_practice(p,2) = data{test_id(p),1};
end

% - imagery practice - %
test_id = find(strcmp(data(:,9),'ima_practice'));
nTrials = length(test_id);
D.ima_practice = zeros(nTrials,3);
for t = 1:nTrials
    if strcmp(data{test_id(t),7},'right')
        D.ima_practice(t,1) = 1;
    end
    D.ima_practice(t,2) = data{test_id(t),11}-48;
    D.ima_practice(t,3) = data{test_id(t),1};
end

% - main blocks - %
test_id = find(strcmp(data(:,9),'main_test'));
nMainTrials = length(test_id);
D.main = zeros(nMainTrials,4); 
for t = 1:nMainTrials
    D.main(t,1) = data{test_id(t),16}; % visibility
    D.main(t,2) = data{test_id(t),15}; % conditon id
    D.main(t,3) = strcmp(data{test_id(t),13},'true'); % said present?
    D.main(t,4) = data{test_id(t),1}; % RT
end

% imagery check
check_id = find(strcmp(data(:,9),'ima_check'));
num_blocks = length(check_id);
trls_block = nMainTrials/num_blocks;
for m = 1:num_blocks
    trl_idx = (m-1)*trls_block+1:m*trls_block;
    D.main(trl_idx,6) = strcmp(data{check_id(m),13},'true'); % correct?
end


% -- debrief questions -- %
idx = find(strcmp(data(:,4),'survey-text'));
questions = data{idx(2),14};
D.age = questions{1,2};
D.ima_question = questions{2,2};
D.ima_check = questions{3,2};
D.comments = questions{4,2};


fclose('all');
