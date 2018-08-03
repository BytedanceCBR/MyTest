import sys, os, re

red_print = '\033[1;31;40m'
yellow_print = '\033[1;33;40m'
blue_print = '\033[1;36;40m'
white_print = '\033[1;37;40m'
exit_print = '\033[0m'

# NSLog
log_pos_arr = []
# addObserver
observer_pos_arr = []
# #warning
warn_code_arr = []
# //TODO
todo_code_arr = []
# //FIXME
fixme_code_arr = []
# removeObserver
remove_observer_flag = 0
# /* */
pair_anotation = 0
# category initialize
category_initialize_flag = 0
# strong delegate
strong_delegate_arr = []
# NSString NSArray NSDictionary NSData use copy
use_copy_arr = []
# init use instancetype return type
use_instancetype_arr = []

def check_single_anotation(pattern):
	has_single_ano = pattern.startswith('//')
	is_fixme = check_fixme_code(pattern)
	is_todo = check_todo_code(pattern)
	ret = has_single_ano and not is_fixme and not is_todo
	return ret

def check_left_anotation(pattern):
	return pattern.startswith('/*')

def check_right_anotation(pattern):
	return pattern.endswith('*/')

def check_nslog(pattern):
	if pattern.find('NSLog') != -1:
		return True
	return False

def check_warn_code(pattern):
	if pattern.find('#warning') != -1:
		return True
	return False

def check_add_observer_code(pattern):
	if remove_observer_flag == 1:
		return False
	elif pattern.find('addObserver:') != -1:
		return True
	return False

def check_remove_observer_code(pattern):
	if pattern.find('removeObserver:') != -1:
		return True
	return False

def check_todo_code(pattern):
	if pattern.find('TODO') != -1:
		return True
	return False

def check_fixme_code(pattern):
	if pattern.find('FIXME') != -1:
		return True
	return False

def check_category_initialize(pattern, filename):
	if filename.find('+') != -1 and pattern.find('(void)initialize') != -1:
		return True
	return False

def check_strong_delegate(pattern):
	if re.match(r'@property.*strong.*delegate.*', pattern, re.I) != None:
		return True
	return False

def check_use_copy(pattern):
	if re.match(r'@property.*strong.*(NSArray|NSString|NSDictionary|NSData).*', pattern) != None:
		return True
	return False

def check_use_instancetype(pattern):
	if re.match(r'-\s*\((\s*|\s*\S+\s+)id\s*\)\s*init.*', pattern) != None:
		return True
	return False

def check_filter(pattern):
	global pair_anotation
	ret = False
	if pattern == '':
		ret = True
	if check_single_anotation(pattern):
		ret = True
	if pair_anotation == 1:
		ret = True
	if check_left_anotation(pattern):
		pair_anotation = 1
		ret = True
	if check_right_anotation(pattern):
		pair_anotation = 0
		ret = True
	return ret

def print_analyze_result():
	log_count = len(log_pos_arr)
	if log_count:
		print '%sYou have %d NSLog, at %s, Please replace it with LOGD or delete it.%s' % (yellow_print, log_count, log_pos_arr, exit_print)
	warn_code_count = len(warn_code_arr)
	if warn_code_count:
		print '%sYou have %d warn code, at %s, Please fix it.%s' % (yellow_print, warn_code_count, warn_code_arr, exit_print)
	observer_count = len(observer_pos_arr)
	if remove_observer_flag == 0 and observer_count:
		print '%sYou have %d addObserver, at %s with no removeObserver, Please fix it.%s' % (yellow_print, observer_count, observer_pos_arr, exit_print)
	todo_count = len(todo_code_arr)
	if todo_count:
		print '%sYou have %d TODO code, at %s, Please fix it.%s' % (yellow_print, todo_count, todo_code_arr, exit_print)
	fixme_count = len(fixme_code_arr)
	if fixme_count:
		print '%sYou have %d FIXME code, at %s, Please fix it.%s' % (yellow_print, fixme_count, fixme_code_arr, exit_print)
	if category_initialize_flag:
		print '%sOverride initialize in category will invalidate the initialize method in original class. Care!!!%s' % (yellow_print, exit_print)
	strong_delegate_count = len(strong_delegate_arr)
	if strong_delegate_count:
		print "%sYou have %d strong property which has delegate in it's name at %s, please rename them.%s" % (yellow_print, strong_delegate_count, strong_delegate_arr, exit_print)
	use_copy_count = len(use_copy_arr)
	if use_copy_count:
		print '%sYou have %d strong property which is suggested to use copy at %s, please replace them.%s' % (yellow_print, use_copy_count, use_copy_arr, exit_print)
	use_instance_count = len(use_instancetype_arr)
	if use_instance_count:
		print '%sYou have %d init method which return type is (id) at %s, please replace them with (instance).%s' % (yellow_print, use_instance_count, use_instancetype_arr, exit_print)

def start_analyze_file(file_name):
	global remove_observer_flag
	global observer_pos_arr
	global category_initialize_flag
	print '%sstart analyze %s%s' % (blue_print, file_name, exit_print)
	with open(file_name) as fd:
		line_idx = 1
		for line in fd:
			pattern = line.strip()
			if check_filter(pattern):
				line_idx += 1
				continue
			if check_nslog(pattern):
				log_pos_arr.append(line_idx)
			if check_warn_code(pattern):
				warn_code_arr.append(line_idx)
			if check_add_observer_code(pattern):
				observer_pos_arr.append(line_idx)
			if check_remove_observer_code(pattern):
				remove_observer_flag = 1
				observer_pos_arr[:] = []
			if check_todo_code(pattern):
				todo_code_arr.append(line_idx)
			if check_fixme_code(pattern):
				fixme_code_arr.append(line_idx)
			if check_category_initialize(pattern, file_name):
				category_initialize_flag = True
			if check_strong_delegate(pattern):
				strong_delegate_arr.append(line_idx)
			if check_use_copy(pattern):
				use_copy_arr.append(line_idx)
			if check_use_instancetype(pattern):
				use_instancetype_arr.append(line_idx)
			line_idx += 1

	print_analyze_result()
	print '%sfinish analyze %s%s' % (blue_print, file_name, exit_print)
	print ''

def do_reset():
	global log_pos_arr
	log_pos_arr = []
	global observer_pos_arr
	observer_pos_arr = []
	global warn_code_arr
	warn_code_arr = []
	global todo_code_arr
	todo_code_arr = []
	global fixme_code_arr
	fixme_code_arr = []
	global remove_observer_flag
	remove_observer_flag = 0
	global pair_anotation
	pair_anotation = 0
	global category_initialize_flag
	category_initialize_flag = 0
	global strong_delegate_arr
	strong_delegate_arr = []
	global use_copy_arr
	use_copy_arr = []
	global use_instancetype_arr
	use_instancetype_arr = []

def traverse_file_arr(file_arr, root_dir):
	for file_name in file_arr:
		do_reset()
		file_name = file_name.strip()
		if file_name == '':
			continue
		path = root_dir + '/' + file_name
		start_analyze_file(path)

def extract_file():
	if len(sys.argv) != 3:
		print '%scount of parameters is wrong%s' % (red_print, exit_print)
		exit(2)
	path = sys.argv[1]
	root_dir = sys.argv[2]
	with open(path) as fd:
		for line in fd:
			file_arr = re.split(r'\s*modified:\s*|\s*new\ file:\s*', line)
			traverse_file_arr(file_arr, root_dir)


if __name__ == '__main__':
	extract_file()