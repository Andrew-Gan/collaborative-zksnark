import re
import matplotlib.pyplot as plt
import matplotlib.colors as mcolors

categories = {
    'Communication': ['To', 'From'],
    'Setup': ['Generating', 'Polynomial', 'commit'],
    'Proving': ['prove'],
    'Verification': ['evaluation'],
}
runtime = {c: 0 for c in categories}
totalRuntime = 0

fp = open('mpc-snarks/output/delegator-filtered.out')
for line in fp:
    if 'ns' in line:
        continue
    timeStr = re.search(r'\d+\..+', line).group(0)
    timeNum = float(re.search(r'\d+\.\d+', timeStr).group(0))
    if 'µs' in timeStr:
        timeNum /= 1000
    for cat, kw in categories.items():
        if any([k in line for k in kw]):
            runtime[cat] += timeNum
            totalRuntime += timeNum
            break

colors=list(mcolors.TABLEAU_COLORS.keys())

currTime = 0
for i, t in enumerate(runtime.values()):
    plt.barh(y=0, width=t, height=0.5, left=currTime, color=colors[i])
    currTime += t

# breakdown of proving phase
categories = {
    'Communication': ['To', 'From'],
    'Setup': ['Generating', 'Polynomial', 'commit'],
    'Proving': ['prove'],
    'Verification': ['evaluations'],
}

msm_inner = 0
fp = open('mpc-snarks/output/delegator_full.out')
for line in fp:
    if 'End:     MSM inner' in line:
        timeStr = re.search(r'\d+\..+', line).group(0)
        timeNum = float(re.search(r'\d+\.\d+', timeStr).group(0))
        if 'µs' in timeStr:
            timeNum /= 1000
        msm_inner += timeNum
msm_inner_reduction = msm_inner * (1 - 1 / 1.45)

currTime = 0
for i, [e, t] in enumerate(runtime.items()):
    if e == 'Proving':
        t -= msm_inner_reduction
    plt.barh(y=-1, width=t, height=0.5, left=currTime, color=colors[i])
    currTime += t

plt.xlabel('Time (ms)')
plt.yticks([0, -1], ['CPU', 'GPU'])
plt.title('Collaborative ZK-Snark Runtime Share')
plt.ylim(-2, 2)
plt.legend([k + ' ' + f'{runtime[k]/totalRuntime:.1%}' for k in categories.keys()])
plt.savefig('plot.png')
