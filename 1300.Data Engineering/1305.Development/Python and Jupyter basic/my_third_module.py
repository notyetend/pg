
val_mod = 'Hello world'

def my_func_one(n):    # write Fibonacci series up to n
    print(n)
    
def my_func_two(n):   # return Fibonacci series up to n
    print(n)

def print_my_name():
    print(__name__)

class MyDog:
    name = ''

print('__name__: ' + __name__)
    
if __name__ == '__main__':
    print('Called from %s' %(__name__))
    import sys
    print(sys.argv[1] + '...')